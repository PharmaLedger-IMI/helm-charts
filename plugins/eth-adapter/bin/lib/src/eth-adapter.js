async function processFlags(){
    const argv = require('minimist')(process.argv)

    if (argv.h || argv.help){
        return require('./utils').showHelp();
    }
    if (!argv.i){
        console.log('Input values.yaml file not provided.\n\n');
        return require('./utils').showHelp();
    }

    if (!argv.o){
        console.log('Output json file not provided.\n\n');
        return require('./utils').showHelp();
    }


    await dlFilesAndWriteJsonFile(argv.i, argv.o);

}

async function dlFilesAndWriteJsonFile(inputValuesYamlFile, outputJsonFile){
    const path = require('path');
    const inputValuesPath = path.resolve(inputValuesYamlFile);

    const yaml = require('yaml');
    const fs = require('fs');
    const inputYamlFile = fs.readFileSync(inputValuesPath).toString('utf8');
    const parsedInputFile = yaml.parse(inputYamlFile);
    const  utils = require('./utils');
    const jsonData = {};
    jsonData.genesis = await utils.dlFile(parsedInputFile.quorum.genesis_file_location);
    jsonData.data = "";
    const dlsources = parsedInputFile.quorum.other_files_to_download;
    for (let i = 0; i < dlsources.length ; i++) {
            jsonData.data+=await utils.dlFile(dlsources[i])+";";
    }
    fs.writeFileSync(outputJsonFile,JSON.stringify(jsonData));
}

processFlags().then(
    () => {},
    (err) => {console.log(err);}
);

