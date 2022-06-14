# Network Policies

Network Policies increase the level of security as they define the allowed traffic flow between pods/components.

## Cluster prerequisites

You need a network policy enforcement engine, e.g.

- [Calico](https://projectcalico.docs.tigera.io/getting-started/kubernetes/helm)
- [Cilium](https://docs.cilium.io/en/v1.9/gettingstarted/k8s-install-managed/)

## Example by using Kubernetes Network Policies

This example demonstrate how to whitelist traffic flow from epi application to ethadapter to quorum node.

In addition to other helm values, set these configuration values:

```yaml
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

## Links

- [https://kubernetes.io/docs/concepts/services-networking/network-policies/](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Network Policy Editor](https://editor.cilium.io/)