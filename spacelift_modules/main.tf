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

resource "spacelift_stack" "cdk_stack" {

  github_enterprise {
    namespace = "ming-raf"
  }

  cloudformation {
    entry_template_file = var.entry_template_file
    region              = "ap-southeast-2"
    template_bucket     = "spacelift-test"
    stack_name          = var.cfn_stack_name
  }

  autodeploy     = true
  space_id       = data.spacelift_space_by_path.development.id
  branch         = "main"
  description    = "Typical CDK stack"
  name           = var.name
  project_root   = var.project_root
  repository     = var.repository
  runner_image   = "public.ecr.aws/s5n0e7e5/ming-spacelift:latest"
  worker_pool_id = var.worker_pool_id
  before_init = [ "curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh" ]
  before_plan = [
    "npm install aws-cdk-lib",
    "cdk bootstrap",
    "cdk synth --output cdk/cdk.out",
    "cdk ls",
  ]
  labels = [ "infracost" ]
}
