function generateValidator(){
    const crypto = require('crypto');
    const entropy = crypto.randomBytes(128);
    const eth = require('eth-crypto');
    const identity = eth.createIdentity(entropy);
    return {
        nodekey:identity.privateKey.slice(2),
        nodeAddress : identity.address.toString(),
        enode : identity.publicKey.toString()
    }
}


function showHelp(){
    return console.log('\n\njoin-network plugin for helm. Generates cryptographic information for the Quorum Blockchain Node\n\n' +
        'Usage:\n' +
        'helm join-network -i <input> -o <output> \n\n' +
        'Plugin flag and commands:\n' +
        '-i           <input values.yaml file path>\n' +
        '-o           <output values.yaml.file path>\n' );
}


module.exports = {
    generateValidator,
    showHelp
}
