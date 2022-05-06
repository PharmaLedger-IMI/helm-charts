

## InstallETHAdapter use case

Install Ethereum Adapter using the shared information from a configuration repository 

Chart name: ethereum-adapter <br/>
Plugin : ethereum-adapter

### Ethereum Adapter deployment

#### Step 1: Clone your private config repository in the folder "private_configs"


1. After the repository was cloned, change the directory to the "private_configs" folder
```shell
cd private_configs
```
2. Create a folder which will represent your installation, like "network_name/charts/ethereum-adapter-deployment" and change the directory to that folder
```shell
cd network_name/charts/ethereum-adapter
```

#### Step 2: Install the helm chart and the plugin

1. Register the official, or the forked helm charts repository
```shell
helm repo add helm-charts https://raw.githubusercontent.com/PharmaLedger-IMI/helm-charts/master/charts/releases
```
2. Install the helm chart _ethereum-adapter_
```shell
helm pull helm-charts/ethereum-adapter --untar
```
3. Install the _ethereum-adapter_ plugin
```shell
helm plugin install https://github.com/PharmaLedger-IMI/helm-pl-plugin
```

#### Step 3: Adjust private_configs/network_name/charts/ethereum-adapter/eth-adapter-values.yaml

The file contains parametrization for different sets of values:
1. specific data for the download of the public shared information
2. different annotations or configurations for the deployment

Example :
```yaml
# the location of the smart contract info uploaded when the smart contract was deployed
# https://raw.githubusercontent.com/username/shared-repository/master/networks/network_name/anchoring.json
smartContractInfoLocation: ""

service:
   # -- Either ClusterIP, NodePort or LoadBalancer.
   # See [https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/)
   type: LoadBalancer
   # -- Port where the service will be exposed
   port: 3000

config:
   # quorum node rpc address
   rpcAddress: "http://quorum-node-rpc:8545"
```

#### Step 4: Install the helm chart

1. Use the _ethereum-adapter_ plugin to download the public shared information. 
   The execution of the plugin will produce
   1. _ethereum-adapter.plugin.json_ file that will contain all the downloaded information, like ABI, smart contract address. The json file will be used by the helm charts.
   
```shell
helm pl-plugin --ethAdapter -i ./eth-adapter-values.yaml -o .
```

2. Install the helm chart
```shell
helm upgrade --install ethadapter pharmaledger-imi/ethadapter -f ./eth-adapter-values.yaml --set-file config.smartContractInfo=../eth-adapter.plugin.json,secrets.orgAccountJson=../smart-contract/orgAccount.json
```

#### Step 5: Backup your installation and private information

Upload to your private repository all the data located in the folder _private_configs/network_name/charts/ethereum-adapter_


