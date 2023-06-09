terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "1.1.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65.0"
    }
  }
}

provider "spacelift" {}

provider "aws" {
  region = "ap-southeast-2"
}

data "spacelift_space_by_path" "development" {
  space_path = "root/development"
}

output "development_space_id" {
  value = data.spacelift_space_by_path.development.id
}