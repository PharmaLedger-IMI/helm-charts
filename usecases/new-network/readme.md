

## NewNetwork use case

Deploy a single quorum node with the node and genesis cryptography generated at runtime. After the deployment, the genesis and node connection information is uploaded to a chosen repository. 

[Chart name: quorum-node](../../charts/quorum-node)<br/>
[Plugin : new-network](https://github.com/PharmaLedger-IMI/helm-pl-plugin)

### Quorum node deployment

1. [Fresh Install](readme.md#fresh-install)
2. [Standard Upgrade of the installation](readme.md#upgrade-the-installation)

### Fresh Install

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
helm repo add helm-charts <helm-charts repository link>
```
2. Download the values for the helm chart _quorum-node_
```shell
helm show values helm-charts/quorum-node > my-values.yaml
```
3. Install the _<pl-deployment-plugin>_ plugin
```shell
helm plugin install https://github.com/PharmaLedger-IMI/helm-pl-plugin
```

#### Step 3: Adjust private_configs/network_name/charts/quorum-node-0/new-network/my-values.yaml

The file contains parametrization for different sets of values:
1. specific data for the upload of the public shared information (example github token, user, email, etc)
2. specific data for the use case network, company name, public blockchain node endpoint and port
3. storage data used by the blockchain deployment
4. different annotations or configurations for the deployment

The structure of the values.yaml file is documented in [quorum-node chart folder](../../charts/quorum-node/readme.md) 

#### Step 4: Install the helm chart

1. Use the _<pl-deployment-plugin> plugin to generate the cryptographic material for the Quorum node. 
   The execution of the plugin will produce:
   1. _new-network.plugin.json_ file that will contain all the generated information, like account, node public crypto data, genesis data. The json file will be used by the new-network helm charts. This file will be preserved in the private repository.
      This file is also used in two ways:
       1. to generate the configmaps for the deployment of the Quorum Node (see step 4.2)
       2. in the post-install step of the helm chart (in 4.2) to generate shared configurations and upload it in the shared repository (documented in https://github.com/PharmaLedger-IMI/helm-charts/blob/master/charts/read.me) 
   
   3. _new-network.plugin.secrets.json_ file that will contain all the private information like private keys/passwords/etc. of the blockchain account and node. This file will be preserved in the private repository.
   
```shell
helm <pl-deployment-plugin> --newNetwork -i ./my-values.yaml -o .
```

2. Install the helm chart
```shell
helm upgrade --install qn-0 . -f ./my-values.yaml
```
3. Upload shared data to the shared-repository

The files that are needed to be uploaded are :
1. enode - contains the enode address
2. enode.ip - contains the public ip or dns by which the quorum node is accessible
3. enode.ip.port - contains the quorum node port
4. validator.address - quorum node address
5. genesis.json - the genesis file generated and used in the quorum node deployment

If the setting git_upload.enabled is _true_, then the files are uploaded by the deployment process.

If the setting git_upload.enabled is _false_, then the files must be uploaded and created by using other means.  

#### Step 5: Backup your installation and private information

Upload to your private repository all the data located in the folder _private_configs/network_name/charts/quorum-node-0_


### Upgrade the installation

#### Step 1: Clone your private config repository in the folder "private_configs"


1. After the repository was cloned, change the directory to the "private_configs" folder
```shell
cd private_configs
```
2. Create a folder which will represent your installation, like "network_name/charts/quorum-node-0" and change the directory to that folder
```shell
cd network_name/charts/quorum-node-0
```

#### Step 2: Update the helm charts

1. Execute:
```shell
helm repo update helm-charts
```

#### Step 3: Adjust private_configs/network_name/charts/quorum-node-0/new-network/my-values.yaml

1. Download the values for the helm chart _quorum-node_ and DON'T CHANGE IT
```shell
helm show values helm-charts/quorum-node > values.yaml
```
2. Check the release notes from breaking changes or resolutions regarding the upgrades
3. Update the values not affecting the use case behaviour with new values in the _private_configs/network_name/charts/quorum-node-0/new-network/my-values.yaml_ file

#### Step 4: Upgrade the installation using the helm chart

2. Install the helm chart

>***NOTE:*** Always use the values.yaml file BEFORE your my-values.yaml file

```shell
helm upgrade --install qn-0 . -f ./values.yaml -f ./my-values.yaml
```

If the setting git_upload.enabled is _true_, then the changed files are uploaded by the deployment process. Otherwise, the changes in the shared repository must be done by using other means.

#### Step 5: Backup your installation information

Upload to your private repository all the data located in the folder _private_configs/network_name/charts/quorum-node-0_
