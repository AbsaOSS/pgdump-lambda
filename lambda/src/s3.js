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

const { S3 } = require("@aws-sdk/client-s3");
const fs = require('fs');

async function uploadMultipart(s3, params, fileObject) {
    const createMultipartUploadResponse = await s3.createMultipartUpload(params);
    const uploadId = createMultipartUploadResponse.UploadId;
    const partSize = 100 * 1024 * 1024; // 100MB
    const fileStream = fs.createReadStream(fileObject.filePath, {highWaterMark: partSize});
    let partNumber = 1;
    let parts = [];

    for await (const chunk of fileStream) {
        const uploadPartResponse = await s3.uploadPart({
            Bucket: params.Bucket,
            Key: params.Key,
            PartNumber: partNumber,
            UploadId: uploadId,
            Body: chunk,
        });

        parts.push({
            ETag: uploadPartResponse.ETag,
            PartNumber: partNumber,
        });

        partNumber++;
    }

    await s3.completeMultipartUpload({
        Bucket: params.Bucket,
        Key: params.Key,
        UploadId: uploadId,
        MultipartUpload: {Parts: parts},
    });
}

async function uploadToS3(event, fileObject) {
    event.PREFIX = event.PREFIX ? event.PREFIX + '/' : '';

    let s3 = new S3({ region: event.REGION });
    let params = {
        Bucket: event.S3_BUCKET,
        Key: `${event.PREFIX}${fileObject.fileName}`,
        Body: fs.createReadStream(fileObject.filePath)
    };

    try {
        await uploadMultipart(s3, params, fileObject);

        return {
            bucket: params.Bucket,
            key: params.Key,
            region: event.REGION,
        };
    } catch (err) {
        throw err;
    }
}

module.exports = uploadToS3;