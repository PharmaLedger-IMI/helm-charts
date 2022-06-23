variable "account_id" {
  type        = string
  description = "The 12 digit account id, e.g. 012345678901."
}
variable "region" {
  type        = string
  description = "AWS region"
}
variable "eks_cluster_name" {
  description = "Name/ID of the EKS Cluster"
  type        = string
}
variable "oidc_provider_arn" {
  type        = string
  description = "ARN of the AWS OIDC Provider associated with the EKS cluster"
}
variable "namespace" {
  type        = string
  description = "The namespace"
}
variable "node_key" {
  type        = string
  description = "The private node key"
  sensitive   = true
}
# variable "genesis_key_store_account" {
#   type        = string
#   description = "Only needed on usecase new network!"
#   sensitive   = true
# }

locals {
  secret = {
    nodekey = var.node_key
#    key = var.genesis_key_store_account
  }
}

# 1. Optional: Create a KMS Key for encrypting the Secret
resource "aws_kms_key" "main" {
  description         = "KMS Key for Kubernetes Secret for ServiceAccount ${var.namespace}/quorum-node"
  enable_key_rotation = true
  # See: https://docs.aws.amazon.com/secretsmanager/latest/userguide/security-encryption.html
  #checkov:skip=CKV_AWS_33: "Ensure KMS key policy does not contain wildcard (*) principal"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid" : "Allow access through AWS Secrets Manager for all principals in the account that are authorized to use AWS Secrets Manager",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : [ "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:CreateGrant", "kms:DescribeKey" ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "kms:ViaService" : "secretsmanager.${var.region}.amazonaws.com",
              "kms:CallerAccount" : "${var.account_id}"
            }
          }
        },
        {
          "Sid": "Enable IAM User Permissions",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::${var.account_id}:root"
          },
          "Action": "kms:*",
          "Resource": "*"
        }
    ]
}
POLICY
}
resource "aws_kms_alias" "main" {
  name          = "alias/eks/${var.eks_cluster_name}/${var.namespace}/quorum-node"
  target_key_id = aws_kms_key.main.key_id
}

# 2. Create the Secret in AWS Secrets Manager
resource "aws_secretsmanager_secret" "main" {
  name_prefix = "${var.eks_cluster_name}-${var.namespace}-quorum-node"
  description = "Kubernetes Secret for ServiceAccount ${var.namespace}/quorum-node"
  kms_key_id  = aws_kms_alias.main.arn

  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = jsonencode(local.secret)
}

# 3. Create IAM policy with permission to get the secret value from Secrets Manager.
resource "aws_iam_policy" "main" {
  name_prefix = "${var.eks_cluster_name}-${var.namespace}-quorum-node"
  description = "Allows getting secret account key from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = [aws_secretsmanager_secret.main.arn]
      },
      {
        Effect = "Allow"
        # https://docs.aws.amazon.com/secretsmanager/latest/userguide/security-encryption.html
        Action   = ["kms:GenerateDataKey", "kms:Decrypt"]
        Resource = [aws_kms_key.main.arn]
      }
    ]
  })
}

# 4. Create an IAM Role for Kubernetes Service Account
# see https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/examples/iam-role-for-service-accounts-eks/main.tf
module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "v5.1.0"

  role_name = "${var.eks_cluster_name}-${var.namespace}-quorum-noder"

  oidc_providers = {
    eks = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:quorum-node"]
    }
  }

  role_policy_arns = {
    main = aws_iam_policy.main.arn
  }
}

# 4. Install/Upgrade helm release
resource "helm_release" "main" {
  name      = "epi-quorum"
  namespace = var.namespace

  repository = "https://pharmaledger-imi.github.io/helm-charts"
  chart      = "quorum-node"
  version    = "0.5.0"

  create_namespace = false
  timeout          = 600
  wait             = true
  wait_for_jobs    = true

  # NOTE: Other configuration values are ommited here! 
  values = [<<EOF
(...)

serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: "${module.iam_role.iam_role_arn}"

secretProviderClass:
  enabled: true
  spec:
    provider: aws
    parameters:
      objects: |
        - objectName: "${aws_secretsmanager_secret.main.arn}"
          objectType: "secretsmanager"
          jmesPath: 
            - path: nodekey
              objectAlias: nodekey

(...)

EOF
  ]
}
