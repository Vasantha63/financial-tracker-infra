# providers.tf
# AWS తో connect అవ్వడానికి — ఒకసారే రాస్తాం

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}