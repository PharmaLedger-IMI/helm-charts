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

function getGenesisExtraData(validator){
    const VANITY_DATA = "0x0000000000000000000000000000000000000000000000000000000000000000";
    const rlp =  require('rlp');
    // ibft = 0x + <32 bytes Vanity> + RLP(List<Validators>, proposer Seals, seals]).
    const validatorList = [validator, null, []];
    const extraDataCoded = rlp.encode(validatorList);
    const extraData = VANITY_DATA + Buffer.from(extraDataCoded).toString('hex');
    return extraData;
}

function generatePassword(){
    const passLength = 20;
    const result           = [];
    const characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const charactersLength = characters.length;
    for ( let i = 0; i < passLength; i++ ) {
        result.push(characters.charAt(Math.floor(Math.random() *
            charactersLength)));
    }
    return result.join('');
}


function createAdmAcc(){

    const keythereum = require('keythereum');
    const params = {keyBytes: 32, ivBytes: 16};
    const dk = keythereum.create(params);
    const password = generatePassword();
// Note: if options is unspecified, the values in keythereum.constants are used.
    const options = {
        kdf: "scrypt", // "pbkdf2" or "scrypt" to use
        cipher: "aes-128-ctr",
        kdfparams: {
            c: 262144,
            dklen: 32,
            prf: "hmac-sha256"
        }
    };

    // synchronous
    const keyObject = keythereum.dump(password, dk.privateKey, dk.salt, dk.iv, options);
    return {
        keyObject: Buffer.from(JSON.stringify(keyObject)).toString('base64'),
        privateKey : dk.privateKey,
        password: password,
        account: '0x'+keyObject.address
    };

}

function showHelp(){
    return console.log('\n\nnode-crypto-gen plugin for helm. Generates cryptographic information for the Quorum Blockchain Node\n\n' +
        'Usage:\n' +
        'helm node-crypto-gen -i <input> -o <output> [command flag]\n\n' +
        'Plugin flag and commands:\n' +
        '-i           <input values.yaml file path>\n' +
        '-o           <output values.yaml.file path>\n' +
        '-genesis     generate crypto for the initial node : genesis and node validator information\n' +
        '-node-crypto generate node validator information\n\n');
}


module.exports = {
    generateValidator,
    getGenesisExtraData,
    createAdmAcc,
    showHelp
}
