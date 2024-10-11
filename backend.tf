terraform {
  backend "s3" {
    # use --backend-config bucket=xxx  to set the bucket name
    region          = "af-south-1"
    encrypt         = true
    key             = "pgdump_lambda/terraform.tfstate"
    acl             = "private"
    dynamodb_table  = "dynamodb-state-locking"
  }
}