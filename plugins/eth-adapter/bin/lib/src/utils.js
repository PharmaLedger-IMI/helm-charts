

function showHelp(){
    return console.log('\n\neth-adapter plugin for helm. Aggregates information from external sources described in the input file into a usable helm chart values file\n\n' +
        'Usage:\n' +
        'helm eth-adapter -i <input> -o <output> \n\n' +
        'Plugin flags:\n' +
        '-i           <input values.yaml file path>\n' +
        '-o           <output values.yaml.file path>\n' +
        '\n\n');
}


async function dlFile(githubUrl){
    const fetch = require('node-fetch');

    try {
        const res = await fetch(githubUrl);
        return res.text();
    } catch (err){
        throw err;
    }
}


module.exports = {
    showHelp,
    dlFile
}
