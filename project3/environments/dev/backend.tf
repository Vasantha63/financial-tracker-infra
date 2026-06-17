# environments/dev/backend.tf
# State S3 లో store అవుతుంది

terraform {
  backend "s3" {
    bucket         = "financial-tracker-tfstate-vasantha"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}