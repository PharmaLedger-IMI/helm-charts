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
  name      = "quorum-node-0"
  namespace = var.namespace

  repository = "https://pharmaledger-imi.github.io/helm-charts"
  chart      = "quorum-node"
  version    = "0.5.0"

  create_namespace = false
  timeout          = 600
  wait             = true
  wait_for_jobs    = true

  values = [<<EOF
image:
  repository: quorumengineering/quorum
  pullPolicy: Always
  tag: "21.7.1"
  sha: "17fdaa26ae682bd7ba1ee0f9cc957fc07582b53aa6c2a6bc800f29c3ad28289e"  # pragma: allowlist secret

use_case:
  newNetwork:
    enabled: false

  joinNetwork:
    enabled: true
    plugin_data_common: >-
      {
        "enode": "todo: the enode of this node",
        "nodeKeyPublic": "todo: the public key of this node",
        "genesis": "todo: genesis JSON file in JSON encoded format"
      }

  updatePartnersInfo:
    enabled: true
    plugin_data_common: >-
      {
        "peers": [
          {
            "company": "company-a",
            "enode": "todo: enode of company A",
            "enodeAddress": "todo: DNS name or IP address",
            "enodeAddressPort": "30303",
            "nodeKeyPublic": "todo: public key of node from company A"
          },
          {
            "company": "company-b",
            "enode": "todo: enode of company B",
            "enodeAddress": "todo: DNS name or IP address",
            "enodeAddressPort": "30303",
            "nodeKeyPublic": "todo: public key of node from company B"
          },
          {
            "company": "company-c",
            "enode": "todo: enode of company C",
            "enodeAddress": "todo: DNS name or IP address",
            "enodeAddressPort": "30303",
            "nodeKeyPublic": "todo: public key of node from company C"
          }
        ]
      }

persistence:
  data:
    storageClassName: "<todo: name of the StorageClass, e.g. gp3-encrypted>"
    size: "40Gi"
    volumeSnapshots:
      preUpgradeEnabled: true
      finalSnapshotEnabled: true
      className: "<todo: Name of the VolumeSnapshotClass, e.g. csi-aws>"

  logs:
    enabled: false

service:
  p2p:
    type: LoadBalancer
    port: 30303
    annotations:
      # optional: Pretty DNS name
      # external-dns.alpha.kubernetes.io/hostname: "my-quorum.mycompany.com"
      service.beta.kubernetes.io/aws-load-balancer-name: "<todo: a nice for for the NLB>"
      service.beta.kubernetes.io/aws-load-balancer-eip-allocations: <todo: The EIP, e.g. eipallow-somevalue>
      service.beta.kubernetes.io/aws-load-balancer-subnets: <todo: a single public subnet, must be the same AZ as in nodeAffinity, e.g. pl-fra-public-eu-central-1a>
      service.beta.kubernetes.io/aws-load-balancer-type: "external"
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
      service.beta.kubernetes.io/aws-load-balancer-ip-address-type: ipv4
      service.beta.kubernetes.io/aws-load-balancer-target-group-attributes: preserve_client_ip.enabled=true,deregistration_delay.timeout_seconds=120,deregistration_delay.connection_termination.enabled=true,stickiness.enabled=true,stickiness.type=source_ip
      service.beta.kubernetes.io/aws-load-balancer-healthcheck-healthy-threshold: "2"
      service.beta.kubernetes.io/aws-load-balancer-healthcheck-unhealthy-threshold: "2"
      service.beta.kubernetes.io/aws-load-balancer-attributes: load_balancing.cross_zone.enabled=false
    loadBalancerSourceRanges:
      - 1.2.3.4/32   # other Company A
      - 2.3.4.5/32   # other company B
      - 3.4.5.6/32   # other company C

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: topology.kubernetes.io/zone
          operator: In
          values:
          - eu-central-1a

resources:
  limits:
    cpu: "1"
    memory: 2Gi
  requests:
    cpu: 100m
    memory: 2Gi

podSecurityContext:
  seccompProfile:
    type: RuntimeDefault

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

extraResources:
- |
  apiVersion: snapscheduler.backube/v1
  kind: SnapshotSchedule
  metadata:
    name: daily
    namespace: ${var.namespace}
  spec:
    retention:
      maxCount: 30
    schedule: 30 0 * * *

- |
  apiVersion: snapscheduler.backube/v1
  kind: SnapshotSchedule
  metadata:
    name: hourly
    namespace: ${var.namespace}
  spec:
    retention:
      maxCount: 24
    schedule: 15 * * * *

- |
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: ingress-from-nodes
    namespace: ${var.namespace}
  spec:
    podSelector:
      matchLabels:
        app.kubernetes.io/name: quorum-node-0
    policyTypes:
      - Ingress
    ingress:
      - from:
          - ipBlock:
              cidr: 1.2.3.4/32   # other company A
          - ipBlock:
              cidr: 2.3.4.5/32   # other company B
          - ipBlock:
              cidr: 3.4.5.6/32   # other company C
        ports:
          - port: 30303

- |
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: egress-to-nodes
    namespace: ${var.namespace}
  spec:
    podSelector:
      matchLabels:
        app.kubernetes.io/name: quorum-node-0
    policyTypes:
      - Egress
    egress:
      # Please note: This allows worldwide egress on port 30303.
      # You can also provide a full list of all public ip addresses of all other nodes here to really use a whitelist approach.
      - to:
          - ipBlock:
              cidr: 0.0.0.0/0
        ports:
          - port: 30303

- |
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: ingress-from-ethadapter
    namespace: ${var.namespace}
  spec:
    podSelector:
      matchLabels:
        app.kubernetes.io/name: quorum-node-0
    policyTypes:
      - Ingress
    ingress:
      - from:
          - namespaceSelector:
              matchLabels:
                kubernetes.io/metadata.name: <todo: namespace of ethadapter>
            podSelector:
              matchLabels:
                app.kubernetes.io/name: <todo: value of the label "app.kubernetes.io/name" for ethadapter>
        ports:
          - port: 8545

- |
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: ingress-from-prometheus
    namespace: ${var.namespace}
  spec:
    podSelector:
      matchLabels:
        app.kubernetes.io/name: quorum-node-0
    policyTypes:
      - Ingress
    ingress:
      - from:
          - namespaceSelector:
              matchLabels:
                kubernetes.io/metadata.name: <todo: namespace of prometheus>
            podSelector:
              matchLabels:
                app: prometheus
        ports:
          - port: 9545

- |
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: egress-to-dns
    namespace: ${var.namespace}
  spec:
    podSelector:
      matchLabels:
        app.kubernetes.io/name: quorum-node-0
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
