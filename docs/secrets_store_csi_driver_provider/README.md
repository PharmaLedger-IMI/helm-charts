# Kubernetes Secrets Store CSI Driver and Provider Installation

Some helm charts (e.g. ethadapter, epi, quorum-node) provide the option to use [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/concepts.html) for mounting sensitive application configuration data/secrets from a vault solution like AWS Secrets Manager or HashiCorp Vault instead of storing secret values in a Kubernetes Secret and mounting that Kubernetes Secret. Please see Cluster Prerequisites for installing the components appropriately.

## Cluster prerequisites

In order to use CSI Secrets Driver and to mount secrets from e.g. AWS Secrets Manager, you need to install these components properly:

1. [Kubernetes Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/)
2. One of the supported providers for your Kubernetes distribution:
    - [AWS Provider](https://github.com/aws/secrets-store-csi-driver-provider-aws)

        See [this terraform example](aws_driver_and_provider.tf) how to install the driver and AWS provider.

        Further links:

        - [https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html](https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html)
        - [https://www.eksworkshop.com/beginner/110_irsa/preparation/](https://www.eksworkshop.com/beginner/110_irsa/preparation/)

    - [Azure Provider](https://azure.github.io/secrets-store-csi-driver-provider-azure/)
    - [GCP Provider](https://github.com/GoogleCloudPlatform/secrets-store-csi-driver-provider-gcp)
    - [Hashicorp Vault Provider](https://github.com/hashicorp/secrets-store-csi-driver-provider-vault)

3. On AWS EKS you also need a solution for associating an AWS IAM Role to a ServiceAccount whose token is mounted into the pod. The IAM role is being used to get the secret from AWS Secrets Manager. The recommended way is to enable IAM Roles for Service Accounts - see [Link 1](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) and [Link 2](https://www.eksworkshop.com/beginner/110_irsa/preparation/). There might be similar approaches for other Kubernetes distributions. Please refer to the documentation.

