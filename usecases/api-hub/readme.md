

## installApiHub use case

Install a new ApiHub running instance

Chart name: install-api-hub <br/>
Plugin : None

### ApiHub deployment

#### Step 1: Clone your private config repository in the folder "private_configs"


1. After the repository was cloned, change the directory to the "private_configs" folder
```shell
cd private_configs
```
2. Create a folder which will represent your installation, like "network_name/charts/epi-api-hub" and change the directory to that folder
```shell
cd network_name/charts/epi-api-hub
```

#### Step 2: Install the helm chart and the plugin

1. Register the official, or the forked helm charts repository
```shell
helm repo add helm-charts https://raw.githubusercontent.com/PharmaLedger-IMI/helm-charts/master/charts/releases
```
2. Install the helm chart _install-api-hub_
```shell
helm pull helm-charts/install-api-hub --untar
```


#### Step 3: Adjust private_configs/network_name/charts/epi-api-hub/install-api-hub/values.yaml

The file contains parametrization for different sets of values:
1. specific data for the upload of the public shared information
2. specific data for the use case network, company name, etc.
3. specific deployed use case data like,ethereum-adapter endpoint, domain, subdomain, bdns information, etc.
4. storage data used by the api-hub deployment
5. different annotations or configurations for the deployment

#### Step 4: Install the helm chart

1. Install the helm chart
```shell
helm install epi . -f ./values.yaml
```

#### Step 5: Backup your installation and private information

Upload to your private repository all the data located in the folder _private_configs/network_name/charts/epi-api-hub_


