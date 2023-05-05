terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
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

resource "spacelift_stack" "development_admin" {

  github_enterprise {
    namespace = "ming-raf"
  }

  administrative = true
  autodeploy   = true
  space_id     = "root"
  branch       = "main"
  description  = "Admin stack to manage the development space"
  name         = "Development Admin"
  project_root = ".spacelift/spaces/development"
  repository   = "spacelift-test"
  terraform_version = "1.4.6"
}

resource "spacelift_stack" "staging_admin" {

  github_enterprise {
    namespace = "ming-raf"
  }

  administrative = true
  autodeploy   = true
  space_id     = "root"
  branch       = "main"
  description  = "Admin stack to manage the staging space"
  name         = "Staging Admin"
  project_root = ".spacelift/spaces/staging"
  repository   = "spacelift-test"
  terraform_version = "1.4.6"
}

resource "spacelift_stack" "live_admin" {

  github_enterprise {
    namespace = "ming-raf"
  }

  administrative = true
  autodeploy   = true
  space_id     = "root"
  branch       = "main"
  description  = "Admin stack to manage the live space"
  name         = "Live Admin"
  project_root = ".spacelift/spaces/live"
  repository   = "spacelift-test"
  terraform_version = "1.4.6"
}