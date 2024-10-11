# pg_dump Lambda

`pgdump-lambda` is a Node.js-based AWS Lambda function that uses the `pg_dump` utility to back up a PostgreSQL database and uploads the resulting file to an S3 bucket. The function retrieves database credentials from AWS Secrets Manager.

## Setting Up

### Prerequisites

1. **AWS Secrets Manager** or **AWS Systems Manager Parameter Store**: Create a secret or parameter containing the following credentials required by `pg_dump`:
   - `host`
   - `database`
   - `username`
   - `password`
   
   i.e.
   ```json
    {
      "host": "mydb.example.com",
      "database": "mydb",
      "username": "myuser",
      "password": "mypassword"
    }
   ```
2. **AWS SSM Parameters**
    
    The Lambda requires following parameters to be set in AWS SSM Parameter Store:
   - `/${var.team_code}/common_values/account_alias` - AWS Account Alias
   - `/${var.team_code}/common_values/appId` - Application ID
   - `/${var.team_code}/common_values/costCenter` - Cost Center
   - `/${var.team_code}/common_values/teamEmailAddress` - Team Email Address
   - `/${var.team_code}/common_values/application` - Application Name
   - `/${var.team_code}/common_values/environmentType` - Environment Type (dev/prod)
   - `/${var.team_code}/common_values/vpcId` - VPC ID
   
    Most of them are used for tagging the resources created by Terraform but some are used for naming the resources (account_alias, environmentType, vpcId)

### Deployment

Use Terraform to deploy the Lambda function and its associated resources.

#### NPM Build

Before deploying the Lambda function, run `npm install` to install the required dependencies. Terraform deployment expects the `node_modules` directory to be present.

```bash
npm install --production --no-progress
```

#### Required Variables for Deployment

To successfully deploy the `pgdump-lambda` project using Terraform, the following variables are required:

1. **`vpc_id`**: The ID of the VPC where the Lambda function will be deployed.
2. **`kms_encryption_key_arn`**: The ARN of the KMS encryption key used for encrypting sensitive data.
3. **`kms_encryption_key_account_id`**: The account ID associated with the KMS encryption key.
4. **`project_name`**: The name of the project, used for naming resources.
5. **`aws_profile`**: The AWS profile to use for deployment.
6. **`team_code`**: A code representing the team responsible for the project.
7. **`permissions_boundary`**: The ARN of the IAM policy that sets the permissions boundary for the Lambda function's role.
8. **`backup_schedules`**: A map of backup schedules, each containing:
    - `name`: The name of the schedule.
    - `db_secret_arn`: The ARN of the secret in AWS Secrets Manager containing the database credentials.
    - `bucket_object_id_prefix`: The prefix for objects stored in the S3 bucket.
    - `secret_source`: The source of the database credentials (`SSM` or `SECRETS_MANAGER`).

These variables are typically defined in a Terraform variables file (e.g., `config.nonprod.tfvars`).

Example `config.nonprod.tfvars`:

```hcl
vpc_id                        = "vpc-12345"
kms_encryption_key_arn        = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-a123-456a-a12b-a123b456c789"
kms_encryption_key_account_id = 123456789012
project_name                  = "pgdump-lambda"

aws_profile = "nonprod"
team_code   = "abcdefgh"

permissions_boundary = "arn:aws:iam::123456789012:policy/permissions-boundary"

backup_schedules = {
   "test" = {
      name                    = "test"
      db_secret_arn           = "/test/db/backup_credentials"
      bucket_object_id_prefix = "test"
      secret_source           = "SSM"
   },
   "dev" = {
      name                     = "dev"
      db_credentials_parameter = "arn:aws:secretsmanager:us-east-1:123"
      bucket_object_id_prefix  = "dev"
      secret_source            = "SECRETS_MANAGER"
   }
}
```