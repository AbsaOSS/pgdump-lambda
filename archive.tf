data "archive_file" "lambda_pgdump_archive" {
  type = "zip"

  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_pgdump.zip"

  excludes = [
    ".git/*",
    ".git*",
    ".terraform",
    "terraform*",
    ".terraform/*",
    ".gitignore",
    ".DS_Store",
    "terraform.tfstate*",
    "terraform.tfvars*",
    "*.tf",
    ".idea",
    "*.zip"
  ]
}