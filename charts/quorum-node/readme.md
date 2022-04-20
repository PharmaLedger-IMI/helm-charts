# quorum-node


![Version: 0.2.8](https://img.shields.io/badge/Version-0.2.8-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 21.7.1](https://img.shields.io/badge/AppVersion-21.7.1-informational?style=flat-square) 

A Helm chart for the deployment of the quorum node on Kubernetes supporting new-network, join-network and update-partners-info use cases.

## Requirements

- [helm 3](https://helm.sh/docs/intro/install/)

- Deployment use case matrix


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

- Integration with shared repository

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

**Note:** It is recommended to put non-sensitive configuration values in an configuration file and pass sensitive/secret values via commandline.<br/>
The chart requires the execution of the plugin located [here](https://github.com/PharmaLedger-IMI/helm-pl-plugin.git). The details about operating the plugin can be found in the specific use case documentation.<br/>


| Use case | Installation type | Example of command |
|----------|--------------------|-------------------|
| **new-network** | Install/Upgrade |`helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f ./my-values.yaml --set-file use_case.newNetwork.plugin_data_common=./new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=./new-network.plugin.secrets.json`|
| **join-network** | Install/Upgrade |`helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f ./my-values.yaml --set-file use_case.joinNetwork.plugin_data_common=./join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=./join-network.plugin.secrets.json`|
| **new-network**<br/> continued by<br/> **update-partners-info** | Install/Upgrade |`helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f ./my-values.yaml --set-file use_case.newNetwork.plugin_data_common=./new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=./new-network.plugin.secrets.json,use_case.updatePartnersInfo.plugin_data_common=./update-partners-info.plugin.json`|
| **join-network**<br/> continued by<br/> **update-partners-info** | Install/Upgrade |`helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f ./my-values.yaml --set-file use_case.joinNetwork.plugin_data_common=./join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=./join-network.plugin.secrets.json,use_case.updatePartnersInfo.plugin_data_common=./update-partners-info.plugin.json`|

### Expose Service via Load Balancer

**Note:**
By default, for AWS, the quorum node will be exposed by a service of type Classic Load Balancer. You can use [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/) instead to expose it as Network Load Balancer.

Note: You need the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) installed and configured properly.<br/>
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

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | string | `nil` | Pod Affinity |
| blockchain.blockperiod | string | `"3"` | Quorum node block period |
| blockchain.quorum_data_dir | string | `"/etc/quorum/qdata/dd"` |  |
| blockchain.quorum_genesis_location | string | `"/etc/quorum/genesis"` |  |
| blockchain.quorum_home | string | `"/etc/quorum/qdata"` |  |
| deployment.NAT | string | `"1.2.3.4"` | NAT address, used for firewall configuration |
| deployment.company | string | `""` | The name of the company that makes the deployment |
| deployment.enode_address | string | `""` | The Quorum node public ip address |
| deployment.enode_address_port | string | `"30303"` | The Port of the Quorum node public address |
| deployment.network_name | string | `""` | The name of the use case that is being deployed |
| deployment.quorum_node_no | string | `nil` | The number of the deployed Quorum node |
| fullnameOverride | string | `"quorum"` | Override the full name |
| git_shared_configuration.read_write_token | string | `""` | github read-write token |
| git_shared_configuration.repository_name | string | `""` | shared github repository name eg. PharmaLedger-IMI/epi-shared-configuration |
| git_upload.email | string | `""` | The email used by the git in order to upload the data |
| git_upload.enabled | bool | `true` | Enable the automatic upload to the use case shared repository of the shareable data |
| git_upload.git_commit_description | string | `"added genesis and node information"` | The description associated with the commit into the use case shared repository of the shareable data |
| git_upload.git_repo_clone_directory | string | `"helm-charts"` | The folder name where the repository will be cloned when the upload procedure is initiated in the post-install step |
| git_upload.user | string | `""` | The user used by the git in order to upload the data |
| nameOverride | string | `"quorum"` | override the name |
| nodeSelector | object | `{}` | Pod node selector |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| quorum_source.image | string | `"quorum"` | Quorum docker image name |
| quorum_source.registry | string | `"quorumengineering"` | Quorum docker image registry |
| quorum_source.version | string | `"21.7.1"` | Quorum docker image version |
| replicasCount | int | `1` | Number of replicas for the quorum-node !! DO NOT CHANGE !! |
| resources | object | `{}` | Pod resources |
| securityContext | object | `{}` |  |
| service.annotations | string | `nil` | Custom service annotations |
| service.labels | string | `nil` | Custom service labels |
| service.spec.loadBalancerSourceRanges | string | `nil` | A list of CIDR ranges which can access the pod(s) for this service. If list is empty, Kubernetes allows traffic from 0.0.0.0/0 to the Node Security Group(s) |
| shared_repository_conventions.base_shareable_storage_path | string | `"networks"` | The repository base folder name where the shareable data to will be uploaded |
| shared_repository_conventions.enode_address_file_name | string | `"enode.address"` | The name of the file that contains the Quorum Node real ip address or dns |
| shared_repository_conventions.enode_address_port_file_name | string | `"enode.address.port"` | The name of the file that contains the Quorum Node port |
| shared_repository_conventions.enode_file_name | string | `"enode"` | The name of the file that contains the enode |
| shared_repository_conventions.genesis_file_name | string | `"genesis.json"` | The name of the file that contains the genesis file |
| shared_repository_conventions.nat_file_name | string | `"nat"` | The name of the file that contains the NAT address |
| shared_repository_conventions.validator_file_name | string | `"validator.address"` | The name of the file that contains the validator address |
| storage.data | string | `"3Gi"` | Size for the data volume of the Quorum Node |
| storage.logs | string | `"1Gi"` | Size for the logs volume of the Quorum Node |
| storageClass.enabled | bool | `true` | Enable the creation of storage class (AWS specific) |
| tolerations | list | `[]` | Pod tolerations |
| use_case.joinNetwork.enabled | bool | `false` | Enable the join-network use case. Can only be used in collaboration with updatePartnerInfo use case |
| use_case.joinNetwork.plugin_data_common | string | `"\"{\n    \"enode\":\"08\",\n    \"nodeAddress\":\"0x3\",\n    \"genesis\":\"\"\n}\""` |  |
| use_case.joinNetwork.plugin_data_secrets | string | `"\"{\n    \"nodeKey\":\"3b\"\n}\""` |  |
| use_case.newNetwork.enabled | bool | `true` | Enable the new-network use case. Can only be used in collaboration with updatePartnerInfo use case |
| use_case.newNetwork.plugin_data_common | string | `"\"{\n  \"extradata\":\"0x0\",\n  \"enode\":\"\",\n  \"nodeAddress\":\"\",\n  \"genesisAccount\":\"0x89\"\n}\""` |  |
| use_case.newNetwork.plugin_data_secrets | string | `"{ \"genesisKeyStoreAccount\": \"eyJhZGRyZX\", \"nodeKey\": \"47\" }"` |  |
| use_case.updatePartnersInfo.enabled | bool | `false` | Enable the update-partners-info use case. Can only be used in collaboration with new-network pr join-network use case |
| use_case.updatePartnersInfo.peers | list | `[]` | List of company names who act as peers |
| use_case.updatePartnersInfo.plugin_data_common | string | `"{}"` |  |


----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.8.1](https://github.com/norwoodj/helm-docs/releases/v1.8.1)
