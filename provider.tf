provider "aws" {
  region  = "af-south-1"
  profile = var.aws_profile

  default_tags {
    tags = local.tags
  }
}

## Duplicate provider without default tags to avoid dependency graph cycles
provider "aws" {
  region  = "af-south-1"
  alias   = "aws_read_only"

  profile = var.aws_profile
}