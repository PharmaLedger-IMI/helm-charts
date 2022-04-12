# Conventions used for plugin data generations

## new-network use case

### new-network.plugin.json
1. extradata : genesis extradata
2. enode : quorum node enode
3. nodeAddress : quorum node node address
4. genesis account
```json
{
  "extradata": "0x0000000000000000000000000000000000000000000000000000000000000000d8d5944a53ddbb6fac99fbb5231178adde5dc35ed84d5f80c0",
  "enode": "72dd5bd15bc1e5cd25514804fe435e6a2a2d1bbe357e7928b8b14f500cf38434c5a3f2f6889240efb4cf709d3bbbe8c5b37a35872e8aaeca0ee48d309a878a2c",
  "nodeAddress": "0x4a53DDBb6FAc99fBB5231178addE5dc35eD84d5F",
  "genesisAccount": "0x8ab055faa44ffd27a3dc732b67d7a48b216a2709"
}

```

### new-network.plugin.secrets.json

1. nodeKey : quorum node node key
2. genesisKeyStoreAccount : base64 quorum node account info
3. genesisKeyStoreAccountEncryptionPassword
4. genesisAccountPrivateKey
```json
{
  "nodeKey": "e3d06efec4a7dbbc1e689b098c8af7036ffdfe4bb5960a7f32c69a0886047a8f",
  "genesisKeyStoreAccount": "eyJhZGRyZXNzIjoiOGFiMDU1ZmFhNDRmZmQyN2EzZGM3MzJiNjdkN2E0OGIyMTZhMjcwOSIsImNyeXB0byI6eyJjaXBoZXIiOiJhZXMtMTI4LWN0ciIsImNpcGhlcnRleHQiOiI0NTAzYjQzYzk2MjBmZTRmZTJiZGUyODU1NDY4MGU1ZjI5YzFjYzE2MWE0NWNhMDk4NTAzM2I5ZTc5YmZjZWNjIiwiY2lwaGVycGFyYW1zIjp7Iml2IjoiMzhhZjAyMGRkN2RmZjJkZTU4NjgxZTI5N2JlOTIwZjcifSwibWFjIjoiOTkyMThlNGQyYjk0MzkxNzgxNGY3MTUxOTQxOGY1YTEwZDYxMTcwY2U1OGQ1ZDE5ZmNiNjI3MzkxYjYyY2VlNyIsImtkZiI6InNjcnlwdCIsImtkZnBhcmFtcyI6eyJka2xlbiI6MzIsIm4iOjI2MjE0NCwiciI6OCwicCI6MSwic2FsdCI6ImExYTQ5MThmZjBjYWZkNjVhNTg2MzkyMTMxMmM4MTBhNGRmMjg4NTcyZjMwZTRkMzE4ZGFlYjQ2MzcwYzQ2MGIifX0sImlkIjoiMDZhY2E0ZDAtZDZhNy00OWVkLWE5MWMtMWEyMWIwZmFmZmNkIiwidmVyc2lvbiI6M30=",
  "genesisKeyStoreAccountEncryptionPassword": "NY2znIsPPSwAytf7aQI1",
  "genesisAccountPrivateKey": {
    "type": "Buffer",
    "data": [...]
  }
}

```

## join-network use case

### join-network.plugin.json

1. enode: Quorum node enode
2. nodeAddress: Quorum node address
3. genesis: downloaded genesis file 

```json
{
  "enode": "235fdd126d12804f75afafb205bf288db9b7729fc783b9a77acd77d5d31d96c1abeaeee9795400cb6e090dc185b99561d64607b76200003e1444f04b385fe96d",
  "nodeAddress": "0x2B2e7e62055B3F60165D9c27765b18B666eC999b",
  "genesis": "{\n    \"alloc\": {\n      \"0x8ab055faa44ffd27a3dc732b67d7a48b216a2709\": {\n         \"balance\": \"1000000000000000000000000000\"\n      }\n    },\n  \"coinbase\": \"0x0000000000000000000000000000000000000000\",\n  \"config\": {\n    \"homesteadBlock\": 0,\n    \"byzantiumBlock\": 0,\n    \"constantinopleBlock\": 0,\n    \"petersburgBlock\": 0,\n    \"istanbulBlock\": 0,\n    \"eip150Block\": 0,\n    \"eip150Hash\": \"0x0000000000000000000000000000000000000000000000000000000000000000\",\n    \"eip155Block\": 0,\n    \"eip158Block\": 0,\n    \"maxCodeSizeConfig\": [\n      {\n        \"block\": 0,\n        \"size\": 32\n      }\n    ],\n    \"chainId\": 10,\n    \"isQuorum\": true,\n    \"istanbul\": {\n      \"epoch\": 30000,\n      \"policy\": 0\n    }\n  },\n  \"difficulty\": \"0x1\",\n  \"extraData\": \"0x0000000000000000000000000000000000000000000000000000000000000000d8d5944a53ddbb6fac99fbb5231178adde5dc35ed84d5f80c0\",\n  \"gasLimit\": \"0xE0000000\",\n  \"mixHash\": \"0x63746963616c2062797a616e74696e65206661756c7420746f6c6572616e6365\",\n  \"nonce\": \"0x0\",\n  \"parentHash\": \"0x0000000000000000000000000000000000000000000000000000000000000000\",\n  \"timestamp\": \"0x00\"\n}"
}

```

### join-network.plugin.secrets.json

1. nodeKey: Quorum node node key

```json
{"nodeKey":"0c522ba3181bbe82695f92f9258359099d1ea48314185da15d1b72d48c3384b8"}
```

## update-partners-info use case

### update-partners-info.plugin.json

1. peers : list of the known peers
    1. enode : partner quorum node enode
    2. nodeAddress : partner quorum node address
    3. enodeAddress : partner quorum node ip or dns
    4. enodeAddressPort : partner quorum node port

```json
{
  "peers": [
    {
      "enode": "235fdd126d12804f75afafb205bf288db9b7729fc783b9a77acd77d5d31d96c1abeaeee9795400cb6e090dc185b99561d64607b76200003e1444f04b385fe96d",
      "nodeAddress": "0x2B2e7e62055B3F60165D9c27765b18B666eC999b",
      "enodeAddress": "quorum-node-1",
      "enodeAddressPort": "30303"
    }
  ]
}

```
