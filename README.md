# Helm charts

## NewNetwork use case

Deploy a single quorum node with the node and genesis cryptography generated at runtime. After the deployment, the genesis and node connection information is uploaded to a chosen github repository 

### Quorum node deployment

#### Step 1: Clone the repository
```sh
git clone https://github.com/PharmaLedger-IMI/helm-charts.git
```
After the repository was cloned, you must install the helm plugin
```sh
cd helm-charts
helm plugin install ./plugins/new-network
```
#### Step2: Install Quorum-Start helm chart
First we must use the <i>new-network <i/> helm plugin to generate the cryptography required by the Quorum Node
```shell
helm new-node -i ./charts/quorum-start/values.yaml -o ./charts/quorum-start/gen-values.yaml
```
After the values are updated with the required cryptographic material, install de helm chart
```shell
helm install qn-0 ./charts/quorum-start -f ./charts/quorum-start/gen-values.yaml
```

After the deployment is finished, install the blockchain explorer in order to check the node

#### Quorum Blockchain explorer deployment
Execute :
```shell
helm install quorum-explorer ./charts/blockchain-explorer
```

Access the blockchain explorer in order check the node, block generation, etc.


## Demo eth-adapter

The eth-adapter plugin will download the configured file or files from a chosen source. The source is configured in  ./charts/ethereum-adapter/values.yaml.
The plugin will produce a json file, that it is used in the chart.

### Step 1 : Install the eth-adapter plugin
```shell
helm install plugin ./plugins/eth-adapter
```

### Step 2: Use the eth-adapter plugin to gather the genesis file and/or other information from different/same locations
```shell
helm eth-adapter -i ./charts/ethereum-adapter/values.yaml -o ./charts/ethereum-adapter/common.json
```

### Step 3: Install the ethereum-adapter helm chart
The helm chart will deploy a config map containing the information gathered from remote repositories
```shell
helm install eth-0 ./charts/ethereum-adapter/
```

