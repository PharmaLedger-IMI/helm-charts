# quorum-node

![Version: 0.5.1](https://img.shields.io/badge/Version-0.5.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 21.7.1](https://img.shields.io/badge/AppVersion-21.7.1-informational?style=flat-square)

A Helm chart for the deployment of the quorum node on Kubernetes supporting new-network, join-network and update-partners-info use cases.

## Requirements

- [helm 3](https://helm.sh/docs/intro/install/)

## Changelog

See [Changelog](./CHANGELOG.md) for significant changes!

## Usage

- [Here](./README.md#values) is a full list of all configuration values.
- The [values.yaml file](./values.yaml) shows the raw view of all configuration values.
<!-- - [**FULL SAMPLE**](./docs/full_sample/README.md) with multiple features combined. -->

## Features

- Security by default:
  - SecurityContext
  - Non-root user
  - readonly filesystem
- Option to create VolumeSnapshots on *helm upgrade* or before deletion of the helm release.
<!-- - Option to mount sensitive/secret via *CSI Secrets Driver* from a vault solution like AWS Secrets Manager, Azure Key Vault, GCP Secrets Manager or HashiCorp Vault instead of using *Kubernetes Secret*. See [here](./docs/secret_provider_class/README.md) for details. -->
- Option to provide `extraResources` like Network Policies. See [here](./docs/network_policies/README.md) for details.

## Deployment use case matrix

| Use case | Configuration |
|----------|--------|
| **new-network** | `use_case.newNetwork.enabled:` **true**<br/>`use_case.joinNetwork.enabled:` **false**<br/>`use_case.updatePartnersInfo.enabled:` **false**|
| **join-network** | `use_case.newNetwork.enabled:` **false**<br/>`use_case.joinNetwork.enabled:` **true**<br/>`use_case.updatePartnersInfo.enabled:` **false**|
| **new-network**<br/> continued by<br/> **update-partners-info** | `use_case.newNetwork.enabled:` **true**<br/>`use_case.joinNetwork.enabled:` **false**<br/>`use_case.updatePartnersInfo.enabled:` **true**|
| **join-network**<br/> continued by<br/> **update-partners-info** | `use_case.newNetwork.enabled:` **false**<br/>`use_case.joinNetwork.enabled:` **true**<br/>`use_case.updatePartnersInfo.enabled:` **true**|

## Installing the Chart

These samples demonstrate how to pass the configuration settings provided by the plugin which is located [here](https://github.com/PharmaLedger-IMI/helm-pl-plugin.git).

**Note:** In case you are using the plugin mechanism, read the details about operating the plugin which can be found in the specific use case documentation.

| Use case | Installation type | Example of command |
|----------|--------------------|-------------------|
| **new-network** | Install/Upgrade |<code>helm upgrade --install quorum-node-0 pharmaledger-imi/quorum-node --version=0.5.1 \\<br/>-f ./my-values.yaml \\<br/>--set-file use_case.newNetwork.plugin_data_common=./new-network.plugin.json \\<br/>--set-file use_case.newNetwork.plugin_data_secrets=./new-network.plugin.secrets.json</code>|
| **join-network** | Install/Upgrade |<code>helm upgrade --install quorum-node-0 pharmaledger-imi/quorum-node --version=0.5.1 \\<br/>-f ./my-values.yaml \\<br/>--set-file use_case.joinNetwork.plugin_data_common=./join-network.plugin.json \\<br/>--set-file use_case.joinNetwork.plugin_data_secrets=./join-network.plugin.secrets.json</code>|
| **new-network**<br/> continued by<br/> **update-partners-info** | Install/Upgrade |<code>helm upgrade --install quorum-node-0 pharmaledger-imi/quorum-node --version=0.5.1 \\<br/>-f ./my-values.yaml \\<br/>--set-file use_case.newNetwork.plugin_data_common=./new-network.plugin.json \\<br/>--set-file use_case.newNetwork.plugin_data_secrets=./new-network.plugin.secrets.json \\<br/>--set-file use_case.updatePartnersInfo.plugin_data_common=./update-partners-info.plugin.json</code>|
| **join-network**<br/> continued by<br/> **update-partners-info** | Install/Upgrade |<code>helm upgrade --install quorum-node-0 pharmaledger-imi/quorum-node --version=0.5.1 \\<br/>-f ./my-values.yaml \\<br/>--set-file use_case.joinNetwork.plugin_data_common=./join-network.plugin.json \\<br/>--set-file use_case.joinNetwork.plugin_data_secrets=./join-network.plugin.secrets.json \\<br/>--set-file use_case.updatePartnersInfo.plugin_data_common=./update-partners-info.plugin.json</code>|

## Further configuration options

- [Mount Secrets from Vault Solution via Secrets Store CSI Driver](./docs/secret_provider_class/README.md)
- [Network Policies](./docs/network_policies/README.md)
<!-- - [Expose Service via Load Balancer](./docs/load_balancer/README.md) -->
<!-- - [AWS Load Balancer Controller: Expose Service via Ingress](./docs/aws_lb_controller_ingress/README.md) -->

## Backup: Create VolumeSnapshot of data volume before upgrading and before deletion of helm release

Note: Ensure Volume Snapshotting has been set up appropriately.

```yaml
persistence:
  data:
    (...)
    volumeSnapshots:
      preUpgradeEnabled: true
      finalSnapshotEnabled: true
      className: "<Name of the VolumeSnapshotClass>"

```

### Expose Service via Load Balancer

**Note:**
By default, for AWS, the quorum node will be exposed by a service of type Classic Load Balancer. You can use [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/) instead to expose it as Network Load Balancer.

Note: You need the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) installed and configured properly.

Example of configuration for Network Load Balancer in the **my-values.yaml** file:

```yaml
annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "external"
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
    service.beta.kubernetes.io/aws-load-balancer-name: echo-server-yaml
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: instance
    service.beta.kubernetes.io/aws-load-balancer-ip-address-type: ipv4
    service.beta.kubernetes.io/aws-load-balancer-target-group-attributes: preserve_client_ip.enabled=true,deregistration_delay.timeout_seconds=120,deregistration_delay.connection_termination.enabled=true,stickiness.enabled=true,stickiness.type=source_ip
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-healthy-threshold: "2"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-unhealthy-threshold: "2"
    service.beta.kubernetes.io/aws-load-balancer-eip-allocations: eipalloc-0aa2e63a9a1551278
    service.beta.kubernetes.io/aws-load-balancer-subnets: eks-ireland-1-vpc-public-eu-west-1b
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "false"
spec:
  loadBalancerSourceRanges:
    - 8.8.8.8/32
    - 8.8.4.4/32
```

## Values

*Note:* Please scroll horizontally to show more columns (e.g. description)!

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for scheduling a pod. See [https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) Notes for AWS: We want to schedule the pod in a certain availability zone, here eu-west-1a Must be the same zone as the NLB - see service annotation service.beta.kubernetes.io/aws-load-balancer-subnets Please note, that your nodes must be labeled accordingly! See [https://kubernetes.io/docs/reference/labels-annotations-taints/#topologykubernetesiozone](https://kubernetes.io/docs/reference/labels-annotations-taints/#topologykubernetesiozone) |
| deploymentStrategy.type | string | `"Recreate"` |  |
| extraResources | string | `nil` | An array of extra resources that will be deployed. This is useful e.g. for custom resources like SnapshotSchedule provided by [https://github.com/backube/snapscheduler](https://github.com/backube/snapscheduler). |
| fullnameOverride | string | `""` | Override the full name |
| git.image.pullPolicy | string | `"Always"` | Image Pull Policy |
| git.image.repository | string | `"alpine/git"` | The repository of the container image containing kubectl |
| git.image.sha | string | `"b24112a7b8524b87cc1d086459f5ce894d179dc63ffc27d9356cec45606e92e3"` | sha256 digest of the image. Do not add the prefix "@sha256:" <br/> Defaults to image digest for "alpine/git:v2.32.0", see [https://hub.docker.com/layers/kubectl/bitnami/kubectl/1.21.8/images/sha256-f9814e1d2f1be7f7f09addd1d877090fe457d5b66ca2dcf9a311cf1e67168590?context=explore](https://hub.docker.com/layers/kubectl/bitnami/kubectl/1.21.8/images/sha256-f9814e1d2f1be7f7f09addd1d877090fe457d5b66ca2dcf9a311cf1e67168590?context=explore) <!-- # pragma: allowlist secret --> |
| git.image.tag | string | `"v2.32.0"` | The Tag of the image containing kubectl. Minor Version should match to your Kubernetes Cluster Version. |
| git.podSecurityContext | object | `{"fsGroup":65534,"runAsGroup":65534,"runAsUser":65534}` | Pod Security Context for the pod running kubectl. See [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) |
| git.resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Resource constraints for the pre-builder and cleanup job |
| git.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":65534,"runAsNonRoot":true,"runAsUser":65534}` | Security Context for the container running kubectl See [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) |
| image.pullPolicy | string | `"Always"` | Image Pull Policy |
| image.repository | string | `"quorumengineering/quorum"` | The repository of the Quorum container image |
| image.sha | string | `""` | sha256 digest of the image. Do not add the prefix "@sha256:" |
| image.tag | string | `"21.7.1"` | Image tag |
| imagePullSecrets | list | `[]` | Secret(s) for pulling an container image from a private registry. See [https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) |
| kubectl.image.pullPolicy | string | `"Always"` | Image Pull Policy |
| kubectl.image.repository | string | `"bitnami/kubectl"` | The repository of the container image containing kubectl |
| kubectl.image.sha | string | `"f9814e1d2f1be7f7f09addd1d877090fe457d5b66ca2dcf9a311cf1e67168590"` | sha256 digest of the image. Do not add the prefix "@sha256:" <br/> Defaults to image digest for "bitnami/kubectl:1.21.8", see [https://hub.docker.com/layers/kubectl/bitnami/kubectl/1.21.8/images/sha256-f9814e1d2f1be7f7f09addd1d877090fe457d5b66ca2dcf9a311cf1e67168590?context=explore](https://hub.docker.com/layers/kubectl/bitnami/kubectl/1.21.8/images/sha256-f9814e1d2f1be7f7f09addd1d877090fe457d5b66ca2dcf9a311cf1e67168590?context=explore) <!-- # pragma: allowlist secret --> |
| kubectl.image.tag | string | `"1.21.8"` | The Tag of the image containing kubectl. Minor Version should match to your Kubernetes Cluster Version. |
| kubectl.podSecurityContext | object | `{"fsGroup":65534,"runAsGroup":65534,"runAsUser":65534}` | Pod Security Context for the pod running kubectl. See [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) |
| kubectl.resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Resource constraints for the pre-builder and cleanup job |
| kubectl.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":65534,"runAsNonRoot":true,"runAsUser":65534}` | Security Context for the container running kubectl See [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) |
| nameOverride | string | `""` | override the name |
| nodeSelector | object | `{}` | Node Selectors in order to assign pods to certain nodes. See [https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| persistence.data.accessModes | list | `["ReadWriteOnce"]` | AccessModes for the data PVC. See [https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) |
| persistence.data.annotations | object | `{}` | Annotations for the data PVC. |
| persistence.data.dataSource | object | `{}` | DataSource option for cloning an existing volume or creating from a snapshot for data PVC. Take a look at values.yaml for more details. |
| persistence.data.existingClaim | string | `""` | The name of an existing PVC to use instead of creating a new one. |
| persistence.data.finalizers | list | `["kubernetes.io/pvc-protection"]` | Finalizers for data PVC. See [https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storage-object-in-use-protection](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storage-object-in-use-protection) |
| persistence.data.selectorLabels | object | `{}` | Selector Labels for the data PVC. See [https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector) |
| persistence.data.size | string | `"3Gi"` | Size of the data PVC volume. |
| persistence.data.storageClassName | string | `""` | Name of the storage class for data PVC. If empty or not set then storage class will not be set - which means that the default storage class will be used. |
| persistence.data.volumeSnapshots.apiVersion | string | `"v1"` | API Version of the "snapshot.storage.k8s.io" resource. See [https://kubernetes.io/docs/concepts/storage/volume-snapshots/](https://kubernetes.io/docs/concepts/storage/volume-snapshots/) |
| persistence.data.volumeSnapshots.className | string | `""` | The Volume Snapshot class name. See [https://kubernetes.io/docs/concepts/storage/volume-snapshot-classes/](https://kubernetes.io/docs/concepts/storage/volume-snapshot-classes/) |
| persistence.data.volumeSnapshots.finalSnapshotEnabled | bool | `false` | Whether to create final snapshot before delete. The name of the VolumeSnapshot will be "<helm release name>-final-<UTC timestamp YYYYMMDDHHMM>", e.g. "epi-final-202206221213" |
| persistence.data.volumeSnapshots.preUpgradeEnabled | bool | `false` | Whether to create snapshots before helm upgrading or not. The name of the VolumeSnapshot will be "<helm release name>-upgrade-to-revision-<helm revision>-<UTC timestamp YYYYMMDDHHMM>", e.g. "epi-upgrade-to-revision-19-202206221211" |
| persistence.data.volumeSnapshots.waitForReadyToUse | bool | `true` | Whether to wait until the VolumeSnapshot is ready to use. Note: On first snapshot this may take a while. |
| persistence.logs.accessModes | list | `["ReadWriteOnce"]` | AccessModes for the logs PVC. See [https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) |
| persistence.logs.annotations | object | `{}` | Annotations for the logs PVC. |
| persistence.logs.dataSource | object | `{}` | DataSource option for cloning an existing volume or creating from a snapshot for logs PVC. Take a look at values.yaml for more details. |
| persistence.logs.enabled | bool | `true` | Enables logging to a persistent volume. if disabled, logging will be to stdout only. |
| persistence.logs.existingClaim | string | `""` | The name of an existing PVC to use instead of creating a new one. |
| persistence.logs.finalizers | list | `["kubernetes.io/pvc-protection"]` | Finalizers for logs PVC. See [https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storage-object-in-use-protection](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storage-object-in-use-protection) |
| persistence.logs.selectorLabels | object | `{}` | Selector Labels for the logs PVC. See [https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector) |
| persistence.logs.size | string | `"1Gi"` | Size of the logs PVC volume. |
| persistence.logs.storageClassName | string | `""` | Name of the storage class for logs PVC. If empty or not set then storage class will not be set - which means that the default storage class will be used. |
| persistence.logs.volumeSnapshots.apiVersion | string | `"v1"` | API Version of the "snapshot.storage.k8s.io" resource. See [https://kubernetes.io/docs/concepts/storage/volume-snapshots/](https://kubernetes.io/docs/concepts/storage/volume-snapshots/) |
| persistence.logs.volumeSnapshots.className | string | `""` | The Volume Snapshot class name. See [https://kubernetes.io/docs/concepts/storage/volume-snapshot-classes/](https://kubernetes.io/docs/concepts/storage/volume-snapshot-classes/) |
| persistence.logs.volumeSnapshots.finalSnapshotEnabled | bool | `false` | Whether to create final snapshot before delete. The name of the VolumeSnapshot will be "<helm release name>-final-<UTC timestamp YYYYMMDDHHMM>", e.g. "epi-final-202206221213" |
| persistence.logs.volumeSnapshots.preUpgradeEnabled | bool | `false` | Whether to create snapshots before helm upgrading or not. The name of the VolumeSnapshot will be "<helm release name>-upgrade-to-revision-<helm revision>-<UTC timestamp YYYYMMDDHHMM>", e.g. "epi-upgrade-to-revision-19-202206221211" |
| persistence.logs.volumeSnapshots.waitForReadyToUse | bool | `true` | Whether to wait until the VolumeSnapshot is ready to use. Note: On first snapshot this may take a while. |
| podAnnotations | object | `{}` | Annotations added to the pod |
| podSecurityContext | object | `{"fsGroup":10000,"runAsGroup":10000,"runAsUser":10000}` | Security Context for the pod. See [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) |
| quorum.dataDirPath | string | `"/quorum/home/dd"` | Directory path to the Quorum Data Dir. Must be beyond 'homeMountPath' in order to store data on the persistent volume. |
| quorum.genesisFilePath | string | `"/quorum/home/genesis/genesis-geth.json"` | File path to genesis file |
| quorum.homeMountPath | string | `"/quorum/home"` | Directory path to where the persistent volume "data" will be mounted to. Also some config file will be mounted there. |
| quorum.log.emitcheckpoints | bool | `true` | If enabled, emit specially formatted logging checkpoints |
| quorum.log.verbosity | int | `3` | Logging verbosity: 0=silent, 1=error, 2=warn, 3=info, 4=debug, 5=detail |
| quorum.logsMountPath | string | `"/quorum/logs"` | Directory path to where the persistent volume "logs" will be mounted to. |
| quorum.metrics.addr | string | `"0.0.0.0"` | Enable stand-alone metrics HTTP server listening interface. |
| quorum.metrics.enabled | bool | `true` | Enable metrics endpoint which allows monitoring, e.g. via Prometheus |
| quorum.metrics.expensive | bool | `false` | Enable expensive metrics collection and reporting. |
| quorum.metrics.port | int | `9545` | Metrics HTTP server listening port. |
| quorum.metrics.prometheusAnnotationsEnabled | bool | `true` | Add annotations for Prometheus to discover metrics endpoint. |
| quorum.miner.blockPeriod | int | `3` | Default minimum difference between two consecutive block's timestamps in seconds |
| quorum.miner.threads | int | `1` | Number of CPU threads to use for mining |
| quorum.networkId | int | `10` | Explicitly set network id |
| quorum.rpc.api | string | `"admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul"` | The activated APIs at RPC endpoint. |
| quorum.rpc.corsDomain | string | `"*"` |  |
| quorum.rpc.vHosts | string | `"*"` | The virtual hostnames for the RPC endpoint to listen for. If you want to restrict it, use {name}-rpc,{name}-rpc.{namespace},{name}-rpc.{namespace}.svc.cluster.local |
| replicasCount | int | `1` | Number of replicas for the quorum-node !! DO NOT CHANGE !! |
| resources | object | `{}` | Pod resources |
| secretProviderClass.apiVersion | string | `"secrets-store.csi.x-k8s.io/v1"` | API Version of the SecretProviderClass |
| secretProviderClass.enabled | bool | `false` | Whether to use CSI Secrets Store (e.g. Azure Key Vault) instead of "traditional" Kubernetes Secret. |
| secretProviderClass.spec | object | `{}` | Spec for the SecretProviderClass. Note: 1. The nodeKey must be mounted as objectAlias nodekey with path nodekey. 2. In case of a new network: The accountkey must be mounted as objectAlias key with path key. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10000,"runAsNonRoot":true,"runAsUser":10000}` | Security Context for the application container See [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) |
| service.p2p.annotations | object | `{}` | Annotations for the P2P service. See AWS, see [https://kubernetes.io/docs/concepts/services-networking/service/#ssl-support-on-aws](https://kubernetes.io/docs/concepts/services-networking/service/#ssl-support-on-aws) For Azure, see [https://kubernetes-sigs.github.io/cloud-provider-azure/topics/loadbalancer/#loadbalancer-annotations](https://kubernetes-sigs.github.io/cloud-provider-azure/topics/loadbalancer/#loadbalancer-annotations) |
| service.p2p.enabled | bool | `true` | Whether to deploy the P2P service or not. |
| service.p2p.loadBalancerSourceRanges | string | `nil` | A list of CIDR ranges to whitelist for ingress traffic to the P2P service if type is LoadBalancer. If list is empty, Kubernetes allows traffic from 0.0.0.0/0 to the Node Security Group(s) |
| service.p2p.port | int | `30303` | Port where the P2P service will be exposed. |
| service.p2p.type | string | `"ClusterIP"` | Either ClusterIP, NodePort or LoadBalancer for P2P Service. See [https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/) |
| service.rpc.annotations | object | `{}` | Annotations for the RPC service. See AWS, see [https://kubernetes.io/docs/concepts/services-networking/service/#ssl-support-on-aws](https://kubernetes.io/docs/concepts/services-networking/service/#ssl-support-on-aws) For Azure, see [https://kubernetes-sigs.github.io/cloud-provider-azure/topics/loadbalancer/#loadbalancer-annotations](https://kubernetes-sigs.github.io/cloud-provider-azure/topics/loadbalancer/#loadbalancer-annotations) |
| service.rpc.enabled | bool | `true` | Whether to deploy the RPC service or not. |
| service.rpc.loadBalancerSourceRanges | string | `nil` | A list of CIDR ranges to whitelist for ingress traffic to the RPC service if type is LoadBalancer. If list is empty, Kubernetes allows traffic from 0.0.0.0/0 to the Node Security Group(s) |
| service.rpc.port | int | `8545` | Port where the RPC service will be exposed. |
| service.rpc.type | string | `"ClusterIP"` | Either ClusterIP, NodePort or LoadBalancer for RPC Service. See [https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/) |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automountServiceAccountToken | bool | `false` | Whether automounting API credentials for a service account is enabled or not. See [https://docs.bridgecrew.io/docs/bc_k8s_35](https://docs.bridgecrew.io/docs/bc_k8s_35) |
| serviceAccount.create | bool | `false` | Specifies whether a service account should be created. Must be true if secretProviderClass.enabled is true |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for scheduling a pod. See [https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| use_case.joinNetwork.enabled | bool | `false` | Enable the join-network use case. Can only be used in collaboration with updatePartnerInfo use case |
| use_case.joinNetwork.plugin_data_common | string | `"{\n  \"enode\": \"joinNetwork_enode\",\n  \"nodeKeyPublic\": \"joinNetwork_nodeKeyPublic\",\n  \"genesis\": \"{ \\\"key\\\": \\n\"value\\\" }\"\n}"` | Non-sensitive data. A JSON object containing three attribute: 1. "enode" = The enode. 2. "nodeKeyPublic" = The public key of the node starting with "0x". 3. "genesis" = The genesis JSON file in JSON encoded format. |
| use_case.joinNetwork.plugin_data_secrets | string | `"{\n  \"nodeKey\": \"joinNetwork_nodeKey\"\n}"` | Sensitive data. A JSON object containing one attribute: 1. "nodeKey" = The secret private node key. |
| use_case.newNetwork.enabled | bool | `true` | Enable the new-network use case. Can only be used in collaboration with updatePartnerInfo use case |
| use_case.newNetwork.plugin_data_common | string | `"{\n  \"extradata\": \"newNetwork_extradata\",\n  \"enode\": \"newNetwork_Enode\",\n  \"nodeKeyPublic\": \"newNetwork_NodeKeyPublic\",\n  \"genesisAccount\": \"newNetwork_genesisAccount\"\n}"` |  |
| use_case.newNetwork.plugin_data_secrets | string | `"{\n  \"genesisKeyStoreAccount\": \"ewogICAgImFkZHJlc3MiOiAidGVzdGRhdGEiLAogICAgImNyeXB0byI6IHsKICAgICAgICAiY2lwaGVyIjogImFlcy0xMjgtY3RyIiwKICAgICAgICAiY2lwaGVydGV4dCI6ICJ0ZXN0ZGF0YSIsCiAgICAgICAgImNpcGhlcnBhcmFtcyI6IHsKICAgICAgICAgICAgIml2IjogInRlc3RkYXRhIgogICAgICAgIH0sCiAgICAgICAgIm1hYyI6ICJ0ZXN0ZGF0YSIsCiAgICAgICAgImtkZiI6ICJzY3J5cHQiLAogICAgICAgICJrZGZwYXJhbXMiOiB7CiAgICAgICAgICAgICJka2xlbiI6IDMyLAogICAgICAgICAgICAibiI6IDI2MjE0NCwKICAgICAgICAgICAgInIiOiA4LAogICAgICAgICAgICAicCI6IDEsCiAgICAgICAgICAgICJzYWx0IjogInRlc3RkYXRhIgogICAgICAgIH0KICAgIH0sCiAgICAiaWQiOiAidGVzdGRhdGEiLAogICAgInZlcnNpb24iOiAzCn0=\",\n  \"nodeKey\": \"newNetwork_NodeKey\"\n}"` | Sensitive data. A JSON object containing two attributes: 1. "genesisKeyStoreAccount" = a base64 encoded value. 2. "nodeKey" = The secret private node key. <!-- pragma: allowlist secret --> |
| use_case.updatePartnersInfo.enabled | bool | `false` | Enable the update-partners-info use case. Can only be used in collaboration with new-network or join-network use case. |
| use_case.updatePartnersInfo.plugin_data_common | string | `"{\n  \"peers\": [\n    {\n      \"enode\": \"peer1_enode\",\n      \"enodeAddress\": \"peer1_enodeAddress\",\n      \"enodeAddressPort\": \"peer1_enodeAddressPort\",\n      \"nodeKeyPublic\": \"peer1_nodeKeyPublic\"\n    },\n    {\n      \"enode\": \"peer2_enode\",\n      \"enodeAddress\": \"peer2_enodeAddress\",\n      \"enodeAddressPort\": \"peer2_enodeAddressPort\",\n      \"nodeKeyPublic\": \"peer2_nodeKeyPublic\"\n    }\n  ]\n}"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.8.1](https://github.com/norwoodj/helm-docs/releases/v1.8.1)
