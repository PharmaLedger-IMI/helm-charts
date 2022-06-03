# quorum-node

![Version: 0.4.2](https://img.shields.io/badge/Version-0.4.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 21.7.1](https://img.shields.io/badge/AppVersion-21.7.1-informational?style=flat-square)

A Helm chart for the deployment of the quorum node on Kubernetes supporting new-network, join-network and update-partners-info use cases.

## Requirements

- [helm 3](https://helm.sh/docs/intro/install/)

## Changelog

- From 0.3.x to 0.4.x
  - Consolidation of ConfigMaps to one ConfigMap for settings and one for scripts.
  - Storing account-key (on new network only) and node (private) key in Kubernetes Secret instead of storing in ConfigMap
  - Security: Run as non root user with readonly filesystem by default
  - Reacts to config changes and restart quorum node [https://helm.sh/docs/howto/charts_tips_and_tricks/#automatically-roll-deployments](https://helm.sh/docs/howto/charts_tips_and_tricks/#automatically-roll-deployments)
  - Follows standard Helm naming conventions (e.g. use `fullnameOverride` to set fix names) and removed function "quorum-node.Identifier"
  - Some minor fixes

## Deployment use case matrix

| Use case | Configuration |
|----------|--------|
| **new-network** | `use_case.newNetwork.enabled:` **true**<br/>`use_case.joinNetwork.enabled:` **false**<br/>`use_case.updatePartnersInfo.enabled:` **false**|
| **join-network** | `use_case.newNetwork.enabled:` **false**<br/>`use_case.joinNetwork.enabled:` **true**<br/>`use_case.updatePartnersInfo.enabled:` **false**|
| **new-network**<br/> continued by<br/> **update-partners-info** | `use_case.newNetwork.enabled:` **true**<br/>`use_case.joinNetwork.enabled:` **false**<br/>`use_case.updatePartnersInfo.enabled:` **true**<br/>`use_case.updatePartnersInfo.peers:` **Required**|
| **join-network**<br/> continued by<br/> **update-partners-info** | `use_case.newNetwork.enabled:` **false**<br/>`use_case.joinNetwork.enabled:` **true**<br/>`use_case.updatePartnersInfo.enabled:` **true**<br/>`use_case.updatePartnersInfo.peers:` **Required**|

Configuration example for the field `use_case.updatePartnersInfo.peers:`

```yaml
use_case:
  updatePartnersInfo:
    peers: [
       company1,
       company2,
       company3
    ]
```

## Integration with shared repository

| Integration with shared repository configuration|
|-----------------------------------|
| `git_shared_configuration.repository_name:` **Required** |
| `git_shared_configuration.read_write_token:` **Required** |

Configuration example for the shared repository:

```yaml
git_shared_configuration:
  # -- shared github repository name eg. PharmaLedger-IMI/epi-shared-configuration
  repository_name: "PharmaLedger-IMI/epi-shared-configuration"
  # -- github read-write token
  read_write_token: "git hub read write token"
```

## Usage

- [Here](./README.md#values) is a full list of all configuration values.
- The [values.yaml file](./values.yaml) shows the raw view of all configuration values.

## Installing the Chart

**Note:** It is recommended to put non-sensitive configuration values in an configuration file and pass sensitive/secret values via commandline.

The chart requires the execution of the plugin located [here](https://github.com/PharmaLedger-IMI/helm-pl-plugin.git). The details about operating the plugin can be found in the specific use case documentation.

| Use case | Installation type | Example of command |
|----------|--------------------|-------------------|
| **new-network** | Install/Upgrade |`helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f ./my-values.yaml --set-file use_case.newNetwork.plugin_data_common=./new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=./new-network.plugin.secrets.json`|
| **join-network** | Install/Upgrade |`helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f ./my-values.yaml --set-file use_case.joinNetwork.plugin_data_common=./join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=./join-network.plugin.secrets.json`|
| **new-network**<br/> continued by<br/> **update-partners-info** | Install/Upgrade |`helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f ./my-values.yaml --set-file use_case.newNetwork.plugin_data_common=./new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=./new-network.plugin.secrets.json,use_case.updatePartnersInfo.plugin_data_common=./update-partners-info.plugin.json`|
| **join-network**<br/> continued by<br/> **update-partners-info** | Install/Upgrade |`helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f ./my-values.yaml --set-file use_case.joinNetwork.plugin_data_common=./join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=./join-network.plugin.secrets.json,use_case.updatePartnersInfo.plugin_data_common=./update-partners-info.plugin.json`|

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
| deployment.NAT | string | `""` | NAT (public IP address your node is sending from) (required on git upload) - e.g. "9.8.7.6" |
| deployment.company | string | `""` | The name of the company that makes the deployment (required on git upload) - e.g. "bayer" |
| deployment.enode_address | string | `""` | The Quorum node public ip address (required on git upload) - e.g. "54.43.32.21" |
| deployment.enode_address_port | string | `"30303"` | The Port of the Quorum node public address (required on git upload) - usually "30303" - e.g. "30303" |
| deployment.network_name | string | `""` | The name of the use case that is being deployed (required on git upload) - e.g. "dev" |
| deployment.quorum_node_no | string | `""` | The number of the deployed Quorum node |
| deploymentStrategy.type | string | `"Recreate"` |  |
| fullnameOverride | string | `""` | Override the full name |
| git.image.pullPolicy | string | `"Always"` | Image Pull Policy |
| git.image.repository | string | `"alpine/git"` | The repository of the container image containing kubectl |
| git.image.sha | string | `"b24112a7b8524b87cc1d086459f5ce894d179dc63ffc27d9356cec45606e92e3"` | sha256 digest of the image. Do not add the prefix "@sha256:" <br/> Defaults to image digest for "alpine/git:v2.32.0", see [https://hub.docker.com/layers/kubectl/bitnami/kubectl/1.21.8/images/sha256-f9814e1d2f1be7f7f09addd1d877090fe457d5b66ca2dcf9a311cf1e67168590?context=explore](https://hub.docker.com/layers/kubectl/bitnami/kubectl/1.21.8/images/sha256-f9814e1d2f1be7f7f09addd1d877090fe457d5b66ca2dcf9a311cf1e67168590?context=explore) <!-- # pragma: allowlist secret --> |
| git.image.tag | string | `"v2.32.0"` | The Tag of the image containing kubectl. Minor Version should match to your Kubernetes Cluster Version. |
| git.podSecurityContext | object | `{"fsGroup":65534,"runAsGroup":65534,"runAsUser":65534}` | Pod Security Context for the pod running kubectl. See [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) |
| git.resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Resource constraints for the pre-builder and cleanup job |
| git.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":65534,"runAsNonRoot":true,"runAsUser":65534}` | Security Context for the container running kubectl See [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) |
| git_shared_configuration.read_write_token | string | `""` | github read-write token (required on git upload) - See [https://github.com/settings/tokens](https://github.com/settings/tokens) for creating a personal access token with "Full control of private repositories". |
| git_shared_configuration.repository_name | string | `""` | shared github repository name (required on git upload) - e.g. "PharmaLedger-IMI/epi-shared-configuration" |
| git_upload.email | string | `""` | The email used by the git in order to upload the data (required on git upload) - e.g. first.last@company.com |
| git_upload.enabled | bool | `true` | Enable the automatic upload to the use case shared repository of the shareable data |
| git_upload.git_commit_description | string | `"added genesis and node information"` | The description associated with the commit into the use case shared repository of the shareable data |
| git_upload.git_repo_clone_directory | string | `"cloned-repo"` | The folder name where the repository will be cloned when the upload procedure is initiated in the post-install step - do not change |
| git_upload.user | string | `""` | The user used by the git in order to upload the data (required on git upload) - e.g. "Firstname Lastname" |
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
| persistence.logs.accessModes | list | `["ReadWriteOnce"]` | AccessModes for the logs PVC. See [https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) |
| persistence.logs.annotations | object | `{}` | Annotations for the logs PVC. |
| persistence.logs.dataSource | object | `{}` | DataSource option for cloning an existing volume or creating from a snapshot for logs PVC. Take a look at values.yaml for more details. |
| persistence.logs.enabled | bool | `true` | Enables logging to a persistent volume. if disabled, logging will be to stdout only. |
| persistence.logs.existingClaim | string | `""` | The name of an existing PVC to use instead of creating a new one. |
| persistence.logs.finalizers | list | `["kubernetes.io/pvc-protection"]` | Finalizers for logs PVC. See [https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storage-object-in-use-protection](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storage-object-in-use-protection) |
| persistence.logs.selectorLabels | object | `{}` | Selector Labels for the logs PVC. See [https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector) |
| persistence.logs.size | string | `"1Gi"` | Size of the logs PVC volume. |
| persistence.logs.storageClassName | string | `""` | Name of the storage class for logs PVC. If empty or not set then storage class will not be set - which means that the default storage class will be used. |
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
| shared_repository_conventions.base_shareable_storage_path | string | `"networks"` | The repository base folder name where the shareable data to will be uploaded |
| shared_repository_conventions.enode_address_file_name | string | `"enode.address"` | The name of the file that contains the Quorum Node real ip address or dns |
| shared_repository_conventions.enode_address_port_file_name | string | `"enode.address.port"` | The name of the file that contains the Quorum Node port |
| shared_repository_conventions.enode_file_name | string | `"enode"` | The name of the file that contains the enode |
| shared_repository_conventions.genesis_file_name | string | `"genesis.json"` | The name of the file that contains the genesis file |
| shared_repository_conventions.nat_file_name | string | `"nat"` | The name of the file that contains the NAT address |
| shared_repository_conventions.validator_file_name | string | `"validator.keypub"` | The name of the file that contains the validators public key (aka address) |
| tolerations | list | `[]` | Tolerations for scheduling a pod. See [https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| use_case.joinNetwork.enabled | bool | `false` | Enable the join-network use case. Can only be used in collaboration with updatePartnerInfo use case |
| use_case.joinNetwork.plugin_data_common | string | `"{\n  \"enode\": \"joinNetwork_enode\",\n  \"nodeKeyPublic\": \"joinNetwork_nodeKeyPublic\",\n  \"genesis\": \"{ \\\"key\\\": \\n\"value\\\" }\"\n}"` |  |
| use_case.joinNetwork.plugin_data_secrets | string | `"{\n  \"nodeKey\": \"joinNetwork_nodeKey\"\n}"` |  |
| use_case.newNetwork.enabled | bool | `true` | Enable the new-network use case. Can only be used in collaboration with updatePartnerInfo use case |
| use_case.newNetwork.plugin_data_common | string | `"{\n  \"extradata\": \"newNetwork_extradata\",\n  \"enode\": \"newNetwork_Enode\",\n  \"nodeKeyPublic\": \"newNetwork_NodeKeyPublic\",\n  \"genesisAccount\": \"newNetwork_genesisAccount\"\n}"` |  |
| use_case.newNetwork.plugin_data_secrets | string | `"{\n  \"genesisKeyStoreAccount\": \"ewogICAgImFkZHJlc3MiOiAidGVzdGRhdGEiLAogICAgImNyeXB0byI6IHsKICAgICAgICAiY2lwaGVyIjogImFlcy0xMjgtY3RyIiwKICAgICAgICAiY2lwaGVydGV4dCI6ICJ0ZXN0ZGF0YSIsCiAgICAgICAgImNpcGhlcnBhcmFtcyI6IHsKICAgICAgICAgICAgIml2IjogInRlc3RkYXRhIgogICAgICAgIH0sCiAgICAgICAgIm1hYyI6ICJ0ZXN0ZGF0YSIsCiAgICAgICAgImtkZiI6ICJzY3J5cHQiLAogICAgICAgICJrZGZwYXJhbXMiOiB7CiAgICAgICAgICAgICJka2xlbiI6IDMyLAogICAgICAgICAgICAibiI6IDI2MjE0NCwKICAgICAgICAgICAgInIiOiA4LAogICAgICAgICAgICAicCI6IDEsCiAgICAgICAgICAgICJzYWx0IjogInRlc3RkYXRhIgogICAgICAgIH0KICAgIH0sCiAgICAiaWQiOiAidGVzdGRhdGEiLAogICAgInZlcnNpb24iOiAzCn0=\",\n  \"nodeKey\": \"newNetwork_NodeKey\"\n}"` | Sensitive data passed by plugin <!-- pragma: allowlist secret --> |
| use_case.updatePartnersInfo.enabled | bool | `false` | Enable the update-partners-info use case. Can only be used in collaboration with new-network pr join-network use case |
| use_case.updatePartnersInfo.peers | list | `[]` | List of company names who act as peers |
| use_case.updatePartnersInfo.plugin_data_common | string | `"{\n  \"peers\": [\n    {\n      \"enode\": \"peer1_enode\",\n      \"enodeAddress\": \"peer1_enodeAddress\",\n      \"enodeAddressPort\": \"peer1_enodeAddressPort\",\n      \"nodeKeyPublic\": \"peer1_nodeKeyPublic\"\n    },\n    {\n      \"enode\": \"peer2_enode\",\n      \"enodeAddress\": \"peer2_enodeAddress\",\n      \"enodeAddressPort\": \"peer2_enodeAddressPort\",\n      \"nodeKeyPublic\": \"peer2_nodeKeyPublic\"\n    }\n  ]\n}"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.8.1](https://github.com/norwoodj/helm-docs/releases/v1.8.1)
