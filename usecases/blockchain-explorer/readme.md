

## installBlockchainExplorer use case

Install the Quorum Blockchain explorer. It is used to monitor the status and health of the blockchain network 

Chart name: quorum-blockchain-explorer <br/>
Plugin : None

### Install the blockchain explorer

#### Step 1: Clone your private config repository in the folder "private_configs"


1. After the repository was cloned, change the directory to the "private_configs" folder
```shell
cd private_configs
```
2. Create a folder which will represent your installation, like "network_name/charts/blockchain-explorer-deployment" and change the directory to that folder
```shell
cd network_name/charts/blockchain-explorer-deployment
```

#### Step 2: Install the helm chart and the plugin

1. Register the official, or the forked helm charts repository
```shell
helm repo add helm-charts https://raw.githubusercontent.com/PharmaLedger-IMI/helm-charts/master/charts/releases
```
2. Install the helm chart _quorum-blockchain-explorer_
```shell
helm pull helm-charts/quorum-blockchain-explorer --untar
```


#### Step 3: Adjust private_configs/network_name/charts/blockchain-explorer-deployment/quorum-blockchain-explorer/values.yaml

The file contains parametrization for different sets of values:
1. quorum rpc service endpoint and port
2. different annotations or configurations for the deployment

#### Step 4: Install the helm chart

1. Install the helm chart
```shell
helm install quorum-blockchain-explorer . -f ./values.yaml
```

#### Step 5: Backup your installation and private information

Upload to your private repository all the data located in the folder _private_configs/network_name/charts/blockchain-explorer-deployment_


