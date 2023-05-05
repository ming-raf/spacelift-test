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

resource "spacelift_stack" "this" {

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

# The spacelift_aws_integration_attachment_external_id data source is used to help generate a trust policy for the integration
data "spacelift_aws_integration_attachment_external_id" "this" {
  integration_id = spacelift_aws_integration.this.id
  stack_id       = spacelift_stack.this.id
  read           = true
  write          = true
}

resource "spacelift_aws_integration_attachment" "this" {
  integration_id = spacelift_aws_integration.this.id
  stack_id       = spacelift_stack.this.id
  read           = true
  write          = true

  # The role needs to exist before we attach since we test role assumption during attachment.
  depends_on = [
    aws_iam_role.this
  ]
}

