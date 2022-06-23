# Network Policies

Network Policies increase the level of security as they define the allowed traffic flow between pods/components.

## Cluster prerequisites

You need a network policy enforcement engine, e.g.

- [Calico](https://projectcalico.docs.tigera.io/getting-started/kubernetes/helm)
- [Cilium](https://docs.cilium.io/en/v1.9/gettingstarted/k8s-install-managed/)

## Example by using Kubernetes Network Policies

This example demonstrates how to whitelist traffic

- ingress traffic from other node peers on p2p communication
- egress traffic from this node to other node peers on p2p communication
- ingress traffic from ethadapter to this node for rpc communication
- ingress traffic from Prometheus for scraping metrics at metrics endpoint
- egress traffic to Kubernetes DNS. Otherwise this node cannot resolve DNS names of other nodes.

In addition to other helm values, set these configuration values:

```yaml
extraResources:
- |
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: ingress-from-nodes
    namespace: <todo: namespace of quorum node>
  spec:
    podSelector:
      matchLabels:
        app.kubernetes.io/name: <todo: value of the label "app.kubernetes.io/name" for quorum node>
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
    namespace: <todo: namespace of quorum node>
  spec:
    podSelector:
      matchLabels:
        app.kubernetes.io/name: <todo: value of the label "app.kubernetes.io/name" for quorum node>
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
    namespace: <todo: namespace of quorum node>
  spec:
    podSelector:
      matchLabels:
        app.kubernetes.io/name: <todo: value of the label "app.kubernetes.io/name" for quorum node>
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
    namespace: <todo: namespace of quorum node>
  spec:
    podSelector:
      matchLabels:
        app.kubernetes.io/name: <todo: value of the label "app.kubernetes.io/name" for quorum node>
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
    namespace: <todo: namespace of quorum node>
  spec:
    podSelector:
      matchLabels:
        app.kubernetes.io/name: <todo: value of the label "app.kubernetes.io/name" for quorum node>
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