

## DeploySmartContract use case

Deploy the Anchoring Smart Contract using the shared information from a configuration repository

Plugin : smart-contract

### Anchoring Smart Contract deployment

#### Step 1: Create a working directory and clone your private config repository in the folder "private_configs"


1. After the repository was cloned, change the directory to the "private_configs" folder
```shell
cd private_configs
```
2. Create a folder which will represent your installation, like "network_name/charts/smart-contract" and change the directory to that folder
```shell
cd network_name/charts/smart-contract
```

#### Step 2: Install the helm plugin
Install the _smart-contract_ plugin
```shell
helm plugin install https://github.com/PharmaLedger-IMI/helm-pl-plugin
```

#### Step 3: Adjust private_configs/network_name/charts/smart-contract/smart-contract.yaml

The file contains parametrization for different sets of values:
1. specific data for the upload of the public shared information
2. remote location of the ethereum anchoring smart contract

Example :
```yaml
smart_contracts:
   - git_upload_smart_contract_filename: "anchoring.json"
     smart_contract_name: "anchoring"
     smart_contract_location: "https://raw.githubusercontent.com/PharmaLedger-IMI/eth-adapter/master/SmartContracts/contracts/Anchoring.sol"

git_upload:
   # --  Enable the automatic upload to the use case shared repository of the shareable data
   enabled: true
   # -- The email used by the git in order to upload the data
   email: ""
   # -- The user used by the git in order to upload the data
   user: ""
   # -- The repository url eg. https://GITHUB-TOKEN:x-oauth-basic@github.com/organisation/shared-repository.git <!-- # pragma: allowlist secret -->
   git_repo_with_access_token: ""
   # -- The repository base folder name where the shareable data to will be uploaded
   git_repo_storage_path: "networks"
   # -- The repository base folder name where the shareable data to will be uploaded
   git_commit_description: "updated smart contract info"

# -- The quorum node pod name
pod_name: "quorum-pod"
# -- The kubernetes namespace
namespace: "default"
# -- The deployment network
network_name: "epi"
```

#### Step 4: Deploy the smart contract

1. Use the _smartContract_ plugin to download the anchoring smart contract and deploy it on the quorum network.
   The execution of the plugin will:
   1. generate the orgAccount.json file that will contain the information for the account used to deploy the smart contract.
   2. deploy the smart contract on the quorum network
   3. generate the file anchoring.json that contains the smart contract address and abi
   4. upload the file anchoring.json in the shared repository if git_upload in smart-contract is enabled ( enable: true )

```shell
helm pl-plugin --smartContract -i ./smart-contract.yaml -o .
```


#### Step 5: Backup your installation and private information

Upload to your private repository all the data located in the folder _private_configs/network_name/charts/smart-contract_


