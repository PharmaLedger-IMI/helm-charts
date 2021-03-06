# Mount secrets from Vault solution

This solution uses the [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/concepts.html) for mounting secrets from a vault solution like AWS Secrets Manager or HashiCorp Vault instead of storing secret values in a Kubernetes Secret and mounting that Kubernetes Secret.

## Cluster prerequisites

- [CSI Driver, provider and IAM solution](./../../../../docs/secrets_store_csi_driver_provider/README.md)

## Example for AWS

Full terraform example, see [here](aws.tf)

1. Optional: Create a KMS Key for encrypting the Secret
2. Create the Secret in AWS Secrets Manager
3. Create an IAM Role (for Kubernetes Service Account) with appropriate permissions to get the secret value from Secrets Manager. The trust relationship must allow the K8S Service Account to assume the role. See links:

    - [https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html)
    - [https://www.eksworkshop.com/beginner/110_irsa/iam-role-for-sa-1/](https://www.eksworkshop.com/beginner/110_irsa/iam-role-for-sa-1/)

4. Set helm values: In addition to other helm values, set these configuration values:

    ```yaml
    # Important!
    # It is not necessary to provide secrets.orgAccountJson or secrets.orgAccountJsonBase64 anymore
    # as its value is stored in AWS Secrets Manager
    serviceAccount:
      create: true
      annotations:
        eks.amazonaws.com/role-arn: "TODO: The ARN of the IAM role"

    secretProviderClass:
      enabled: true
      spec:
        provider: aws
        parameters:
          objects: |
            - objectName: "TODO: ARN or Name of Secret"
              objectType: "secretsmanager"
              objectAlias: "orgAccountJson"

    ```
