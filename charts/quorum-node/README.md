# quorum-node

![Version: 0.2.8](https://img.shields.io/badge/Version-0.2.8-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 21.7.1](https://img.shields.io/badge/AppVersion-21.7.1-informational?style=flat-square)

A Helm chart for the deployment of the quorum node on Kubernetes supporting new-network, join-network and update-partners-info use cases.

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
