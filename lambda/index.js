// Copyright 2024 ABSA Group Limited
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
//     You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
//     Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
//     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//     See the License for the specific language governing permissions and
// limitations under the License.

const pgDump = require('./src/pg_dump');
const uploadToS3 = require('./src/s3');
const deleteFile = require("./src/cleanup");
const getParameter = require("./src/ssm");
const getSecrets = require("./src/secrets");

function validateEventFields(event, requiredFields) {
    requiredFields.forEach(field => {
        if (!event[field]) {
            throw new Error(`${field} not provided in the event data`);
        }
    });
}

exports.handler = async (event) => {
    try {
        validateEventFields(event, ['S3_BUCKET', 'REGION', 'SECRET']);

        let dbSecrets = event.SECRET_SOURCE === 'SECRETS_MANAGER'
            ? await getSecrets(event)
            : await getParameter(event);
        let { database, host, username } = dbSecrets;

        console.info(`Dumping database ${database} from host ${host} using ${username}`);

        let tmpDirectory = '/tmp'
        let dumpResult = await pgDump(event, dbSecrets, tmpDirectory);
        console.info(`Dumped database to ${dumpResult.filePath} with size ${dumpResult.fileSize}`);
        let result = await uploadToS3(event, dumpResult);
        console.info(`File successfully uploaded to S3: ${result.key}`);

        await deleteFile(dumpResult.filePath);
        console.info(`File system cleaned up: ${dumpResult.filePath}`);

        return {
            statusCode: 200,
            body: JSON.stringify(result),
        };
    } catch (error) {
        console.log('err', error);
        throw new Error(JSON.stringify(error));
    }
};
