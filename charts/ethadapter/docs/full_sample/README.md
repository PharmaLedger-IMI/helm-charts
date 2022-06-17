# Full sample

This full sample demonstrates how to use

- Network Policies for securing the ingress and egress.
- Enable [SecComp Profile](https://medium.com/@LachlanEvenson/how-to-enable-kubernetes-container-runtimedefault-seccomp-profile-for-all-workloads-6795624fcbcc) in addition to existing security context setting
- Use AWS Secrets Manager for mounting the secret account key.

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
    config:
      rpcAddress: "TODO: rpc address"
      smartContractInfo: |-
        TODO: JSON

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

    podSecurityContext:
      seccompProfile:
        type: RuntimeDefault

    extraResources:
      - |
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        metadata:
          name: ingress-from-epi
          namespace: <todo: namespace of ethadapter>
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
          namespace: <todo: namespace of ethadapter>
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
          namespace: <todo: namespace of ethadapter>
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


    ```
