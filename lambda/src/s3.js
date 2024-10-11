const { S3 } = require("@aws-sdk/client-s3");
const fs = require('fs');

function uploadToS3(event, fileObject) {

    return new Promise(async (resolve,reject)=>{

        // optional s3 prefix parameter, if not, then use bucket root
        event.PREFIX = event.PREFIX? event.PREFIX+'/' : '';

        // upload the backup file to S3 bucket
        let s3 = new S3({
            region: event.REGION
        });

        let params = {
            Bucket: event.S3_BUCKET,
            Key: `${event.PREFIX}${fileObject.fileName}`,
            Body: fs.createReadStream(fileObject.filePath)
        };

        try {
            const createMultipartUploadResponse = await s3.createMultipartUpload(params);
            const uploadId = createMultipartUploadResponse.UploadId;
            const partSize = 100 * 1024 * 1024; // 100MB
            const fileStream = fs.createReadStream(fileObject.filePath, { highWaterMark: partSize });
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
                MultipartUpload: { Parts: parts },
            });

            resolve({
                bucket: params.Bucket,
                key: params.Key,
                region: event.REGION,
            });
        } catch (err) {
            reject(err);
        }
    });

}

module.exports = uploadToS3;
