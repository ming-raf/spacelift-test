data "spacelift_stack" "dev_admin_stack" {
  stack_id = var.dev_admin_stack_name
}

data "spacelift_space_by_path" "development" {
  space_path = "root/development"
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

resource "spacelift_context_attachment" "app_cdk" {
  context_id = "manual"
  stack_id   = spacelift_stack.cdk_stack.id
  priority   = 0
}

resource "spacelift_context_attachment" "app_cdk_capability" {
  context_id = "iam-capability"
  stack_id   = spacelift_stack.cdk_stack.id
  priority   = 0
}

resource "spacelift_stack_dependency" "cdk_stack" {
  stack_id            = spacelift_stack.cdk_stack.id
  depends_on_stack_id = data.spacelift_stack.dev_admin_stack.id
}

output "stack_id" {
  value = spacelift_stack.cdk_stack.id
}