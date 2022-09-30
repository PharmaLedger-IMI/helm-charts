# quorum-node-metrics-exporter

![Version: 0.2.1](https://img.shields.io/badge/Version-0.2.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.2](https://img.shields.io/badge/AppVersion-v0.2-informational?style=flat-square)

A Helm chart for [quorum-node-metrics-exporter](https://github.com/PharmaLedger-IMI/quorum-node-metrics-exporter)

## Requirements

- [helm 3](https://helm.sh/docs/intro/install/)

## Features

- Security by default:
  - SecurityContext
  - Non-root user
  - readonly filesystem
- Ready-to-use [Prometheus pod-annotations](https://www.weave.works/docs/cloud/latest/tasks/monitor/configuration-k8s/#per-pod-prometheus-annotations)
- Option to provide `extraResources` like
  - [Network Policies](./docs/network_policies/README.md) for fine-grained control of network traffic

## Usage and samples

- [Here](./README.md#values) is a full list of all configuration values.
- The [values.yaml file](./values.yaml) shows the raw view of all configuration values.
- [**FULL SAMPLE**](./docs/full_sample/README.md) with multiple features combined.
- [Network Policies](./docs/network_policies/README.md)

## Installing the Chart

1. Build a container image for [quorum-node-metrics-exporter](https://github.com/PharmaLedger-IMI/quorum-node-metrics-exporter)
2. Push the image to repository
3. Prepare the `my-values.yaml`

    ```yaml
    image:
      repository: "my-repo"
      tag: "my-tag"
    config:
      # -- URL of the Quorum node RPC endpoint, e.g.
      rpcUrl: "http://quorum-node-rpc.quorum:8545"
      # -- The name of the K8S deployment of the Quorum node, e.g.
      deployment: "quorum-node"
      # -- The K8S namespace of the Quorum node, e.g
      namespace: "quorum"
      # -- A string containing an array of peers in JSON format
      peers: |-
        [
          {
            "company-name": "company_a",
            "enode": "4312d5056db7edf8b6...",
            "enodeAddress": "1.2.3.4",
            "enodeAddressPort": "30303"
          },
          {
            "company-name": "company_b",
            "enode": "bc03e0353fe10d0261...",
            "enodeAddress": "2.3.4.5",
            "enodeAddressPort": "30303"
          },
          {
            "company-name": "company_c",
            "enode": "b06bca847a8c27e7d...",
            "enodeAddress": "4.5.6.7",
            "enodeAddressPort": "30303"
          }
        ]

    ```

4. Install the helm release - **IMPORTANT** You must install the metrics into the same namespace like the Quorum node.

    ```shell
    helm upgrade metrics-exporter pharmaledger-imi/quorum-node-metric-exporter --version=0.2.1 \
      --install \
      --namespace=quorum \
      --values ./my-values.yaml

    ```

## Additional helm options

Run `helm upgrade --helm` for full list of options.

- Wait until installation has finished successfully and the deployment is up and running.

    Provide the `--wait` argument and time to wait (default is 5 minutes) via `--timeout`

    ```bash
    helm upgrade metrics-exporter pharmaledger-imi/quorum-node-metric-exporter --version=0.2.1 \
      --install \
      --wait --timeout=600s \
      --namespace=quorum \
      --values my-values.yaml \
    ```

## Uninstalling the Helm Release

To uninstall/delete the `metrics-exporter` release:

```bash
helm delete metrics-exporter \
  --namespace=quorum

```

## Values

*Note:* Please scroll horizontally to show more columns (e.g. description)!

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for scheduling a pod. See [https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| config.deployment | string | `""` | The name of the K8S deployment of the Quorum node, e.g. "quorum-node" |
| config.namespace | string | `""` | The K8S namespace of the Quorum node, e.g "quorum" |
| config.override | string | `""` |  |
| config.peers | string | `""` | A string containing an array of peers in JSON format |
| config.rpcUrl | string | `""` | URL of the Quorum node RPC endpoint, e.g. "http://quorum-node-rpc.quorum:8545" |
| extraResources | string | `nil` | An array of extra resources that will be deployed. This is useful e.g. network policies. |
| fullnameOverride | string | `""` | fullnameOverride completely replaces the generated name. From [https://stackoverflow.com/questions/63838705/what-is-the-difference-between-fullnameoverride-and-nameoverride-in-helm](https://stackoverflow.com/questions/63838705/what-is-the-difference-between-fullnameoverride-and-nameoverride-in-helm) |
| image.pullPolicy | string | `"Always"` | Image Pull Policy |
| image.repository | string | `""` | The repository of the container image |
| image.sha | string | `""` | sha256 digest of the image. If empty string the digest is not being used. Do not add the prefix "@sha256:" <!-- # pragma: allowlist secret --> |
| image.tag | string | `""` | The image tag |
| imagePullSecrets | list | `[]` | Secret(s) for pulling an container image from a private registry. Used for all images. See [https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` | Whether to expose the metrics via an ingress or not. Usually not needed. If you enable it, also set `service.enabled: true` |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` | nameOverride replaces the name of the chart in the Chart.yaml file, when this is used to construct Kubernetes object names. From [https://stackoverflow.com/questions/63838705/what-is-the-difference-between-fullnameoverride-and-nameoverride-in-helm](https://stackoverflow.com/questions/63838705/what-is-the-difference-between-fullnameoverride-and-nameoverride-in-helm) |
| namespaceOverride | string | `""` | Override the deployment namespace. Very useful for multi-namespace deployments in combined charts |
| nodeSelector | object | `{}` | Node Selectors in order to assign pods to certain nodes. See [https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| podAnnotations | object | `{}` | Annotations to add to the pod |
| podLabels | object | `{}` | Labels to add to the pod |
| podSecurityContext | object | `{"fsGroup":65534,"runAsGroup":65534,"runAsUser":65534}` | Pod Security Context. See [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) |
| replicaCount | int | `1` | The number of replicas - should be 1 |
| resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"5m","memory":"64Mi"}}` | Resource constraints |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":65534,"runAsNonRoot":true,"runAsUser":65534}` | Security Context for container See [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) |
| service.clusterIP | string | `"None"` | If type is ClusterIP and clusterIP: "None" a headless service will be created |
| service.enabled | bool | `false` | Whether to expose the metrics via a service or not. Usually not needed. |
| service.port | int | `80` | Service Port |
| service.type | string | `"ClusterIP"` | Service type, should be ClusterIP |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for scheduling a pod. See [https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.8.1](https://github.com/norwoodj/helm-docs/releases/v1.8.1)
