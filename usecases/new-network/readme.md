

## NewNetwork use case

Deploy a single quorum node with the node and genesis cryptography generated at runtime. After the deployment, the genesis and node connection information is uploaded to a chosen repository. 

Chart name: new-network<br/>
Plugin : new-network

### Starting Quorum node deployment

#### Step 1: Clone your private config repository in the folder "private_configs"


1. After the repository was cloned, change the directory to the "private_configs" folder
```shell
cd private_configs
```
2. Create a folder which will represent your installation, like "network_name/charts/quorum-node-0" and change the directory to that folder
```shell
cd network_name/charts/quorum-node-0
```

#### Step 2: Install the helm chart and the plugin

1. Register the official, or the forked helm charts repository
```shell
helm repo add helm-charts https://raw.githubusercontent.com/PharmaLedger-IMI/helm-charts/master/charts/releases
```
2. Install the helm chart _new-network_
```shell
helm pull helm-charts/new-network --untar
```
3. Install the _new-network_ plugin
```shell
helm plugin install https://github.com/PharmaLedger-IMI/helm-charts/plugins/new-network
```

#### Step 3: Adjust private_configs/network_name/charts/quorum-node-0/quorum-start/values.yaml

The file contains parametrization for different sets of values:
1. specific data for the upload of the public shared information (example github token, user, email, etc)
2. specific data for the use case network, company name, public blockchain node endpoint and port
3. storage data used by the blockchain deployment
4. different annotations or configurations for the deployment

#### Step 4: Install the helm chart

1. Use the _new-network_ plugin to generate the cryptographic material for the Quorum node. 
   The execution of the plugin will produce:
   1. _new-network.plugin.json_ file that will contain all the generated information, like account, node public crypto data, genesis data. The json file will be used by the new-network helm charts. This file will be preserved in the private repository.
      This file is also used in two ways:
       1. to generate the configmaps for the deplyment of the Quorum Node (see step 4.2)
       2. in the postinstall step of the helm chart (in 4.2) to generate shared configurations and upload it in the shared repository (documented in https://github.com/PharmaLedger-IMI/helm-charts/edit/master/usecases/new-network/sharedFolderStructure.md) 
   
   3. _new-network.plugin.secrets.json_ file that will contain all the private information like private keys/passwords/etc. of the blockchain account and node. This file will be preserved in the private repository.
   
```shell
helm new-network -i ./values.yaml -o .
```

2. Install the helm chart
```shell
helm install qn-0 . -f ./values.yaml
```

#### Step 5: Backup your installation and private information

Upload to your private repository all the data located in the folder _private_configs/network_name/charts/quorum-node-0_


