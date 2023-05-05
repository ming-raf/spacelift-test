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

resource "spacelift_space" "development" {
  name = "development"

  # Every account has a root space that serves as the root for the space tree.
  # Except for the root space, all the other spaces must define their parents.
  parent_space_id = "root"
  inherit_entities = true

  # An optional description of a space.
  description = "This a child of the root space. It contains all the resources common to the development infrastructure."
}

resource "spacelift_stack" "development_admin" {

  github_enterprise {
    namespace = "ming-raf"
  }

  administrative = true
  autodeploy   = true
  space_id     = "development"
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