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

module "stacks" {
  source = "./stacks/app_cdk_stack"
}

resource "spacelift_stack" "ec2_worker_pool" {

  github_enterprise {
    namespace = "ming-raf"
  }

  autodeploy   = true
  space_id     = data.spacelift_space_by_path.development.id
  branch       = "main"
  name         = "EC2 Worker Pool (Development)"
  project_root = "./spacelift/spaces/development/stacks/worker_pool_stack"
  repository   = "spacelift-test"
}

resource "spacelift_run" "ec2_worker_pool" {
  stack_id = spacelift_stack.ec2_worker_pool.id

  keepers = {
    branch = spacelift_stack.ec2_worker_pool.branch
  }
}

output "ec2_worker_pool_stack_id" {
  description = "ec2_worker_pool stack id"
  value       = spacelift_stack.ec2_worker_pool.id
}