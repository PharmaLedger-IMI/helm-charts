

## DeploySmartContract use case

Deploy the Anchoring Smart Contract using the shared information from a configuration repository

Chart name: ethereum-sc <br/>
Plugin : ethereum-sc

### Anchoring Smart Contract deployment

#### Step 1: Clone your private config repository in the folder "private_configs"


1. After the repository was cloned, change the directory to the "private_configs" folder
```shell
cd private_configs
```
2. Create a folder which will represent your installation, like "network_name/charts/anchor-sc" and change the directory to that folder
```shell
cd network_name/charts/anchor-sc
```

#### Step 2: Install the helm chart and the plugin

1. Register the official, or the forked helm charts repository
```shell
helm repo add helm-charts https://raw.githubusercontent.com/PharmaLedger-IMI/helm-charts/master/charts/releases
```
2. Install the helm chart _ethereum-sc_
```shell
helm pull helm-charts/ethereum-sc --untar
```
3. Install the _ethereum-sc_ plugin
```shell
helm plugin install https://github.com/PharmaLedger-IMI/helm-charts/plugins/ethereum-sc
```

#### Step 3: Adjust private_configs/network_name/charts/anchor-sc/ethereum-sc/values.yaml

The file contains parametrization for different sets of values:
1. specific data for the upload of the public shared information
2. specific data for the use case network, company name, blockchain node service development endpoint and port
3. remote location of the ethereum anchoring smart contract
4. different annotations or configurations for the deployment

#### Step 4: Install the helm chart

1. Use the _ethereum-sc_ plugin to download the anchoring smart contract and generate the organization user that will make the deployment. 
   The execution of the plugin will produce:
   1. _ethereum-sc.plugin.json_ file that will contain all the downloaded information, like the smart contract source code. The json file will be used by the helm charts.
   2. _ethereum-sc.plugin.secrets.json_ file that will contain all the private information like private keys/passwords/etc. of the user that will deploy the smart contract on the blockchain.
   
```shell
helm ethereum-sc -i ./values.yaml -o .
```

2. Install the helm chart
```shell
helm install ethereum-sc . -f ./values.yaml
```

#### Step 5: Backup your installation and private information

Upload to your private repository all the data located in the folder _private_configs/network_name/charts/anchor-sc_


