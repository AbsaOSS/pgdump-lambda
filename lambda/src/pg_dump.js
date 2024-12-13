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

const {exec} = require('child_process')
const path = require('path');
const fs = require('fs');
const binPath = path.join(__dirname, '../bin');
const pgDumpPath = path.join(binPath, 'pg_dump');

async function pgdump(event, secret, tmpDirectory) {
    let date = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '').replace(' ', '_');
    let format = event.PLAIN ? '.sql' : '.backup';
    let args = event.PLAIN ? '' : '-Fc';
    if (event.EXTRA_ARGS) args += (' ' + event.EXTRA_ARGS);

    let envArgs = process.env.PGDUMP_ARGS || '';
    let fileName = `${secret.database}-${date}${format}`;
    let filePath = path.join(tmpDirectory, `${secret.database}-${date}${format}`);

    let command = `${pgDumpPath} ${args} ${envArgs}> ${filePath}`
    await execPromise(command, {
        env: {
            LD_LIBRARY_PATH: binPath,
            PGDATABASE: secret.database,
            PGUSER: secret.username,
            PGPASSWORD: secret.password,
            PGHOST: secret.host,
        }
    });

    let stats = await fs.promises.stat(filePath);
    let fileSize = stats.size;

    if (event.PLAIN) {
        let stdout = await execPromise(`tail -n 3 ${filePath}`);
        if (stdout.toLowerCase().includes('postgresql database dump complete')) {
            return { fileName, filePath, fileSize };
        } else {
                throw new Error('pg_dump failed, unexpected error');
        }
    } else {
        let stdout = await execPromise(`head -n 1 ${filePath}`);
        if (stdout.startsWith('PGDMP')) {
            return { fileName, filePath, fileSize };
        } else {
                throw new Error('pg_dump failed, unexpected error');
        }
    }
}

function execPromise(command, options) {
    return new Promise((resolve, reject) => {
        exec(command, options, (error, stdout, stderr) => {
            if (error) {
                reject(stderr);
            } else {
                resolve(stdout);
            }
        });
    });
}

module.exports = pgdump;
