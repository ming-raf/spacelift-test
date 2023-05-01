terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
      version = "1.1.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
  }
}

provider "spacelift" {}

module "my_workerpool" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-workerpool-on-ec2?ref=v1.5.0"

  configuration = <<-EOT
    export SPACELIFT_TOKEN="${var.worker_pool_config}"
    export SPACELIFT_POOL_PRIVATE_KEY="${var.worker_pool_private_key}"
  EOT

  min_size          = 1
  max_size          = 5
  worker_pool_id    = var.worker_pool_id
  security_groups   = var.worker_pool_security_groups
  vpc_subnets       = var.worker_pool_subnets
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

resource "spacelift_stack" "app-cdk" {

  github_enterprise {
    namespace = "ming-raf"
  }

  cloudformation {
    entry_template_file = "cdk.out/CdkStack.template.json"
    region              = "ap-southeast-2"
    template_bucket     = "s3://spacelift-test"
    stack_name          = "app-cdk"
  }

  administrative = true
  autodeploy   = true
  space_id     = "development"
  branch       = "main"
  description  = "Typical CDK stack"
  name         = "Application CDK"
  project_root = "cdk"
  repository   = "spacelift-test"
  runner_image = "public.ecr.aws/s5n0e7e5/ming-spacelift:latest"
  before_plan  = [
    "cdk bootstrap",
    "cdk synth --output cdk/cdk.out",
    "cdk ls",
  ]
}
