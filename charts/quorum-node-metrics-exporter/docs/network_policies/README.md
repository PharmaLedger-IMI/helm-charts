# Network Policies

Network Policies increase the level of security as they define the allowed traffic flow between pods/components.

## Cluster prerequisites

You need a network policy enforcement engine, e.g.

- [Calico](https://projectcalico.docs.tigera.io/getting-started/kubernetes/helm)
- [Cilium](https://docs.cilium.io/en/v1.9/gettingstarted/k8s-install-managed/)

## Example by using Kubernetes Network Policies

This example demonstrates how to whitelist traffic flow from metrics provider to quorum node.

- allow ingress traffic from Prometheus to metrics provider for querying metrics
- allow egress traffic from metrics provider to Quorum node at RPC endpoint
- allow egress traffic from metrics provider to Kubernetes DNS. Otherwise this node cannot resolve DNS names of RPC endpoint.
- allow egress traffic from metrics provider to Kubernetes API. See policy `quorum-node-metrics-exporter-egress-to-kubeapi` below for further details
- allow ingress traffic to Quorum Node from metrics provider at RPC endpoint

In addition to other helm values of the quorum-node-metrics-provider, set these configuration values:

```yaml
extraResources:
  - |
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: quorum-node-metrics-exporter-ingress-from-prometheus
      namespace: <todo: namespace of quorum>
    spec:
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: prometheus
          podSelector:
            matchLabels:
              app: <todo: namespace of prometheus>
        ports:
        - port: 8000
          protocol: TCP
      podSelector:
        matchLabels:
          app.kubernetes.io/name: <todo: name of metrics-exporter, take a look at labels, e.g. quorum-node-metrics-exporter>
      policyTypes:
      - Ingress

  - |
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: quorum-node-metrics-exporter-egress-to-quorum
      namespace: <todo: namespace of quorum>
    spec:
      egress:
      - ports:
        - port: 8545
          protocol: TCP
        to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: <todo: namespace of quorum>
          podSelector:
            matchLabels:
              app.kubernetes.io/name: <todo: name of quorum node, take a look at labels, e.g. quorum-node-0>
      podSelector:
        matchLabels:
          app.kubernetes.io/name: <todo: name of metrics exporter, take a look at labels, e.g. quorum-node-metrics-exporter>
      policyTypes:
      - Egress

  - |
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: quorum-node-metrics-exporter-egress-to-dns
      namespace: <todo: namespace of quorum>
    spec:
      egress:
      - ports:
        - port: 53
          protocol: UDP
        to:
        - namespaceSelector: {}
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      podSelector:
        matchLabels:
          app.kubernetes.io/name: <todo: name of metrics exporter, take a look at labels, e.g. quorum-node-metrics-exporter>
      policyTypes:
      - Egress

  - |
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: quorum-node-metrics-exporter-egress-to-kubeapi
      namespace: <todo: namespace of quorum>
    spec:
      egress:
      - ports:
        - port: 443
          protocol: TCP
        to:
        # The IP Address of the Kube API Service (see service kubernetes.default)
        - ipBlock:
            cidr: 172.20.0.1/32
        # Determine Kube API Endpoint via
        # kubectl get endpoints --namespace default kubernetes
        # Also see https://pauldally.medium.com/accessing-kubernetes-api-server-when-there-is-an-egress-networkpolicy-af4435e005f9
        - ipBlock:
            cidr: 10.0.17.52/32
        - ipBlock:
            cidr: 10.0.58.124/32
      podSelector:
        matchLabels:
          app.kubernetes.io/name: <todo: name of metrics exporter, take a look at labels, e.g. quorum-node-metrics-exporter>
      policyTypes:
      - Egress

  - |
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: ingress-from-metrics-provider
      namespace: <todo: namespace of quorum>
    spec:
      ingress:
        - ports:
            - protocol: TCP
              port: 8545
          from:
            - podSelector:
                matchLabels:
                  app.kubernetes.io/name: <todo: name of metrics exporter, take a look at labels, e.g. quorum-node-metrics-exporter>
              namespaceSelector:
                matchLabels:
                  kubernetes.io/metadata.name:  <todo: namespace of quorum>
      podSelector:
        matchLabels:
          app.kubernetes.io/name: <todo: name of quorum node, take a look at labels, e.g. quorum-node-0>
      policyTypes:
        - Ingress

```

## Links

- [https://kubernetes.io/docs/concepts/services-networking/network-policies/](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Network Policy Editor](https://editor.cilium.io/)