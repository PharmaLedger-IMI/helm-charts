

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
cd network_name/charts/ethereum-adapter-deployment
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
helm plugin install https://github.com/PharmaLedger-IMI/helm-charts/plugins/ethereum-adapter
```

#### Step 3: Adjust private_configs/network_name/charts/ethereum-adapter-deployment/ethereum-adapter/values.yaml

The file contains parametrization for different sets of values:
1. specific data for the download of the public shared information
2. specific data for the use case network, company name, ethereum adapter endpoint
3. different annotations or configurations for the deployment

#### Step 4: Install the helm chart

1. Use the _ethereum-adapter_ plugin to download the public shared information. 
   The execution of the plugin will produce
   1. _ethereum-adapter.plugin.json_ file that will contain all the downloaded information, like ABI, smart contract address. The json file will be used by the helm charts.
   2. _ethereum-adapter.plugin.secrets.json_ file that will contain all the private information like private keys/passwords/etc. of the account used by the ethereum adapter. The json file will be used by the helm charts.
   
```shell
helm ethereum-adapter -i ./values.yaml -o .
```

2. Install the helm chart
```shell
helm install eth-adapter . -f ./values.yaml
```

#### Step 5: Backup your installation and private information

Upload to your private repository all the data located in the folder _private_configs/network_name/charts/ethereum-adapter-deployment_


