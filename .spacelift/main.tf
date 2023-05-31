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

resource "spacelift_space" "staging" {
  name = "staging"

  # Every account has a root space that serves as the root for the space tree.
  # Except for the root space, all the other spaces must define their parents.
  parent_space_id = "root"
  inherit_entities = true

  # An optional description of a space.
  description = "This a child of the root space. It contains all the resources common to the staging infrastructure."
}

resource "spacelift_space" "live" {
  name = "live"

  # Every account has a root space that serves as the root for the space tree.
  # Except for the root space, all the other spaces must define their parents.
  parent_space_id = "root"
  inherit_entities = true

  # An optional description of a space.
  description = "This a child of the root space. It contains all the resources common to the live infrastructure."
}

resource "spacelift_module" "cdk_stack" {
  name               = "cdk-stack"
  administrative     = true
  branch             = "main"
  project_root       = "spacelift_modules"
  description        = "Deploy pre-configured CDK stack"
  repository         = "spacelift-test"
}