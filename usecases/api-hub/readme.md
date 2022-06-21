

## installApiHub use case

Install a new ApiHub running instance

Chart name: network_name (e.g. epi, csc, iot)<br/>
Plugin : None

### ApiHub deployment

#### Step 1: Clone your private config repository in the folder "private_configs"


1. After the repository was cloned, change the directory to the "private_configs" folder
```shell
cd private_configs
```
2. Create a folder which will represent your installation, like "network_name" and change the directory to that folder
```shell
cd network_name
```

#### Step 2: Update the helm charts

1. Execute
```shell
helm repo update pharmaledger-imi
```

2.Download the values for the helm chart network_name
```shell
helm show values pharmaledger-imi/network_name > my-values.yaml
```


#### Step 3: Adjust private_configs/network_name/my-values.yaml

The file contains parametrization for different sets of values:
1. specific data for the upload of the public shared information
2. specific data for the use case network, company name, etc.
3. specific deployed use case data like,ethereum-adapter endpoint, domain, subdomain, bdns information, etc.
4. storage data used by the api-hub deployment
5. different annotations or configurations for the deployment

#### Step 4: Install the helm chart

1. Install the helm chart
```shell
helm upgrade --install network-name pharmaledger-imi/network-name -f ./my-values.yaml
```

#### Step 5: Backup your installation and private information

Upload to your private repository all the data located in the folder _private_configs/network_name/network_name_


