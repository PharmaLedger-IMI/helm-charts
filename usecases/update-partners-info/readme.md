

## updatePartnersInfo use case

Update, create or remove partners information from the Quorum Blockchain Node. It applies in cases where a new node is joining the network, a node changed its connection details, or a node is leaving the network. 

Chart name: update-partners-info <br/>
Plugin : update-partners-info

### Update Partners Information in a deployed Quorum node

#### Step 1: Clone your private config repository in the folder "private_configs"


1. After the repository was cloned, change the directory to the "private_configs" folder
```shell
cd private_configs
```
2. Create a folder which will represent your installation, like "network_name/charts/update-partners-info-qn-0" and change the directory to that folder
```shell
cd network_name/charts/update-partners-info-qn-0
```

#### Step 2: Install the helm chart and the plugin

1. Register the official, or the forked helm charts repository
```shell
helm repo add helm-charts https://raw.githubusercontent.com/PharmaLedger-IMI/helm-charts/master/charts/releases
```
2. Install the helm chart _update-partners-info_
```shell
helm pull helm-charts/update-partners-info --untar
```
3. Install the _update-partners-info_ plugin
```shell
helm plugin install https://github.com/PharmaLedger-IMI/helm-charts/plugins/update-partners-info
```

#### Step 3: Adjust private_configs/network_name/charts/update-partners-info-qn-0/update-partners-info/values.yaml

The file contains parametrization for different sets of values:
1. specific data for the download of the public shared information
2. specific data for the use case network, company name, etc.
3. different annotations or configurations for the deployment

#### Step 4: Install the helm chart

1. Use the _update-partners-info_ plugin to download and aggregate the quorum node connection details and network validators list. 
   The execution of the plugin will produce:
   1. _update-partners-info.plugin.json_ file that will contain all the generated information, like the list of all validators and enode connections. The json file will be used by the helm charts.
   
```shell
helm update-partners-info -i ./values.yaml -o .
```

2. Install the helm chart
```shell
helm install update-partners-info . -f ./values.yaml
```
The execution of the chart will update all the validators and enode connections. Also, will execute propose operations for the validators.

#### Step 5: Backup your installation and private information

Upload to your private repository all the data located in the folder _private_configs/network_name/charts/update-partners-info-qn-0_


