terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
      version = "1.1.5"
    }
  }
}

provider "spacelift" {}

resource "spacelift_space" "development" {
  name = "development"

  # Every account has a root space that serves as the root for the space tree.
  # Except for the root space, all the other spaces must define their parents.
  parent_space_id = "root"

  # An optional description of a space.
  description = "This a child of the root space. It contains all the resources common to the development infrastructure."
}

resource "spacelift_stack" "app-cdk" {
  cloudformation {
    entry_template_file = "cdk/cdk.out/CdkStack.template.json"
    region              = "ap-southeast-2"
    template_bucket     = "s3://spacelift-test"
    stack_name          = "app-cdk"
  }

  autodeploy   = true
  branch       = "main"
  description  = "Typical CDK stack"
  name         = "Application CDK"
  project_root = "development"
  repository   = "spacelift-test"
  runner_image = "public.ecr.aws/s5n0e7e5/ming-spacelift:latest"
  before_plan = [
    "cdk bootstrap",
    "cdk synth --output cdk/cdk.out",
    "cdk ls",
  ]
}
