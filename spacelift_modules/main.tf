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

data "spacelift_stack" "dev_admin_stack" {
  stack_id = var.dev_admin_stack_name
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
  space_id       = data.spacelift_stack.dev_admin_stack.outputs["development_space_id"]
  branch         = "main"
  description    = "Typical CDK stack"
  name           = var.name
  project_root   = var.project_root
  repository     = var.repository
  runner_image   = "public.ecr.aws/s5n0e7e5/ming-spacelift:latest"
  worker_pool_id = data.spacelift_stack.dev_admin_stack.outputs["worker_pool_id"]
  before_init = [ "curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh" ]
  before_plan = [
    "npm install aws-cdk-lib",
    "cdk bootstrap",
    "cdk synth --output cdk/cdk.out",
    "cdk ls",
  ]
  labels = [ "infracost" ]
}

data "spacelift_aws_integration_attachment_external_id" "cdk_stack" {
  integration_id = data.spacelift_stack.dev_admin_stack.outputs["spacelift_aws_integrations_id"]
  stack_id       = spacelift_stack.cdk_stack.id
  read           = true
  write          = true
}

resource "spacelift_aws_integration_attachment" "cdk_stack" {
  integration_id = data.spacelift_stack.dev_admin_stack.outputs["spacelift_aws_integrations_id"]
  stack_id       = spacelift_stack.cdk_stack.id
  read           = true
  write          = true

  # The role needs to exist before we attach since we test role assumption during attachment.
  depends_on = [
    aws_iam_role.this
  ]
}

resource "spacelift_context_attachment" "app_cdk" {
  context_id = data.spacelift_stack.dev_admin_stack.outputs["spacelift_context_id"]
  stack_id   = spacelift_stack.cdk_stack.id
  priority   = 0
}

resource "spacelift_context_attachment" "app_cdk_capability" {
  context_id = data.spacelift_stack.dev_admin_stack.outputs["spacelift_context_id"]
  stack_id   = spacelift_stack.cdk_stack.id
  priority   = 0
}