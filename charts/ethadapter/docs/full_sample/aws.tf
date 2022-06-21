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
variable "org_account_json" {
  type        = string
  description = "ETH Account and PrivateKey"
  sensitive   = true
}
variable "rpcAddress" {
  type        = string
  description = "The RPC address of quorum node"
}
variable "smartContractAddress" {
  type        = string
  description = "Address of the SmartContract"
}

# 1. Optional: Create a KMS Key for encrypting the Secret
resource "aws_kms_key" "main" {
  description         = "KMS Key for Kubernetes Secret for ServiceAccount ${var.namespace}/ethadapter"
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
  name          = "alias/eks/${var.eks_cluster_name}/${var.namespace}/ethadapter"
  target_key_id = aws_kms_key.main.key_id
}

# 2. Create the Secret in AWS Secrets Manager
resource "aws_secretsmanager_secret" "main" {
  name_prefix = "${var.eks_cluster_name}-${var.namespace}-ethadapter"
  description = "Kubernetes Secret for ServiceAccount ${var.namespace}/ethadapter"
  kms_key_id  = aws_kms_alias.main.arn

  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = var.org_account_json
}

# 3. Create IAM policy with permission to get the secret value from Secrets Manager.
resource "aws_iam_policy" "main" {
  name_prefix = "${var.eks_cluster_name}-${var.namespace}-ethadapter"
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

  role_name = "${var.eks_cluster_name}-${var.namespace}-ethadapter"

  oidc_providers = {
    eks = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:ethadapter"]
    }
  }

  role_policy_arns = {
    main = aws_iam_policy.main.arn
  }
}

locals {
  # Use Abi from https://github.com/PharmaLedger-IMI/eth-adapter/blob/d7e80cd2271f0963801d044497f20290f2ae5857/EthAdapter/k8s/ethadapter-configmap.yaml#L8
  smartContractInfo = {
    address = var.smartContractAddress
    abi     = <<EOF
[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"bool","name":"str","type":"bool"}],"name":"BoolResult","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"bytes1","name":"str","type":"bytes1"}],"name":"Bytes1Result","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"bytes32","name":"str","type":"bytes32"}],"name":"Bytes32Result","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"statusCode","type":"uint256"}],"name":"InvokeStatus","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"bytes","name":"str","type":"bytes"}],"name":"Result","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string[2]","name":"str","type":"string[2]"}],"name":"StringArray2Result","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string[]","name":"str","type":"string[]"}],"name":"StringArrayResult","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"str","type":"string"}],"name":"StringResult","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"str","type":"uint256"}],"name":"UIntResult","type":"event"},{"inputs":[{"internalType":"string","name":"anchorId","type":"string"},{"internalType":"string","name":"newAnchorValue","type":"string"},{"internalType":"uint8","name":"v","type":"uint8"}],"name":"createAnchor","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"anchorId","type":"string"},{"internalType":"string","name":"newAnchorValue","type":"string"},{"internalType":"uint8","name":"v","type":"uint8"}],"name":"appendAnchor","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"anchorId","type":"string"}],"name":"getAllVersions","outputs":[{"internalType":"string[]","name":"","type":"string[]"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"string","name":"anchorId","type":"string"}],"name":"getLastVersion","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"string[]","name":"anchors","type":"string[]"}],"name":"createOrUpdateMultipleAnchors","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"from","type":"uint256"},{"internalType":"uint256","name":"limit","type":"uint256"},{"internalType":"uint256","name":"maxSize","type":"uint256"}],"name":"dumpAnchors","outputs":[{"components":[{"internalType":"string","name":"anchorId","type":"string"},{"internalType":"string[]","name":"anchorValues","type":"string[]"}],"internalType":"struct Anchoring.Anchor[]","name":"","type":"tuple[]"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"totalNumberOfAnchors","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"hash","type":"bytes32"},{"internalType":"bytes","name":"signature","type":"bytes"},{"internalType":"uint8","name":"v","type":"uint8"}],"name":"recover","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"nonpayable","type":"function"}]
EOF
  }
}

# 4. Set helm values: In addition to other helm values, set these configuration values:
resource "helm_release" "main" {
  name      = "ethadapter"
  namespace = var.namespace

  repository = "https://pharmaledger-imi.github.io/helm-charts"
  chart      = "ethadapter"
  version    = "0.7.6"

  create_namespace = false
  timeout          = 600
  wait             = true
  wait_for_jobs    = true

  values = [<<EOF
config:
  rpcAddress: "${var.rpcAddress}"
  smartContractInfo: |-
    ${jsonencode(local.smartContractInfo)}

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
          objectAlias: "orgAccountJson"

podSecurityContext:
  seccompProfile:
    type: RuntimeDefault

extraResources:
  - |
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: ingress-from-epi
      namespace: ${var.namespace}
    spec:
      podSelector: {}
      policyTypes:
        - Ingress
      ingress:
        - from:
            - namespaceSelector:
                matchLabels:
                  kubernetes.io/metadata.name: <todo: namespace of epi>
              podSelector:
                matchLabels:
                  app.kubernetes.io/name: <todo: name of epi, take a look at epi labels, e.g. epi>
          ports:
            - port: 3000

  - |
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: egress-to-quorum
      namespace: ${var.namespace}
    spec:
      podSelector: {}
      policyTypes:
        - Egress
      egress:
        - to:
            - namespaceSelector:
                matchLabels:
                  kubernetes.io/metadata.name: <todo: namespace of quorum>
              podSelector:
                matchLabels:
                  app.kubernetes.io/name: <todo: name of quorum, take a look at quorum labels, e.g. quorum-node-0>
          ports:
            - port: 8545

  - |
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: egress-to-dns
      namespace: ${var.namespace}
    spec:
      podSelector: {}
      policyTypes:
        - Egress
      egress:
        - to:
            - namespaceSelector: {}
              podSelector:
                matchLabels:
                  k8s-app: kube-dns
          ports:
            - port: 53
              protocol: UDP

EOF
  ]
}
