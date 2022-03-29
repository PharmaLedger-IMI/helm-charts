

function processFlags(){
    const argv = require('minimist')(process.argv)
    if (argv.h || argv.help){
        return require('./utils').showHelp();
    }
    if (!argv.i){
        console.log('Input values.yaml file not provided.\n\n');
        return require('./utils').showHelp();
    }

    if (!argv.o){
        console.log('Output values.yaml file not provided.\n\n');
        return require('./utils').showHelp();
    }

    return generateInitialNodeCrypto(argv.i,argv.o);
}



function generateInitialNodeCrypto(inputValuesFile, outputValueFiles){
    const path = require('path');
    const inputValuesPath = path.resolve(inputValuesFile);
    const outputValuesPath = path.resolve(outputValueFiles);

    const yaml = require('yaml');
    const fs = require('fs');
    const inputYamlFile = fs.readFileSync(inputValuesPath).toString('utf8');
    const parsedInputFile = yaml.parse(inputYamlFile);
    const utils = require('./utils');
    const node = utils.generateValidator();
    const genesisextradata = utils.getGenesisExtraData([node.nodeAddress]);
    const admAccount = utils.createAdmAcc();
    parsedInputFile.quorum.extradata = genesisextradata;
    parsedInputFile.quorum.enode = node.enode;
    parsedInputFile.quorum.nodeKey = node.nodekey;
    parsedInputFile.quorum.nodeAdress = node.nodeAddress;
    parsedInputFile.quorum.genesisKeyStoreAccount = admAccount.keyObject;
    parsedInputFile.quorum.genesisAccount = admAccount.account;

    const out = yaml.stringify(parsedInputFile);
    fs.writeFileSync(outputValuesPath,out);
}



processFlags();
