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

resource "spacelift_worker_pool" "aws-ec2" {
  name        = "AWS EC2 Worker Pool"
  csr         = filebase64("../../spacelift.csr")
  description = "Used for all type jobs"
  space_id    = data.spacelift_space_by_path.development.id
}

module "stacks" {
  source = "./stacks"
}



# variable "worker_pool_config" {
#   default = ""
# }

# variable "worker_pool_private_key" {
#   default = ""
# }

# module "my_workerpool" {
#   source = "github.com/spacelift-io/terraform-aws-spacelift-workerpool-on-ec2?ref=v1.5.0"

#   configuration = <<-EOT
#     export SPACELIFT_TOKEN="${var.worker_pool_config}"
#     export SPACELIFT_POOL_PRIVATE_KEY="${var.worker_pool_private_key}"
#   EOT

#   min_size          = 1
#   max_size          = 5
#   worker_pool_id    = var.worker_pool_id
#   security_groups   = var.worker_pool_security_groups
#   vpc_subnets       = var.worker_pool_subnets
# }
