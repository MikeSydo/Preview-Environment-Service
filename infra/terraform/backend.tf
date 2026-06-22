terraform {
  backend "s3" {
    bucket         = "preview-platform-tfstate-mikesydo-511417194779-eu-central-1-an"
    key            = "infra/terraform/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "preview-platform-tflock"
    encrypt        = true
  }
}