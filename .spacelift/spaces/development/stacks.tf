resource "spacelift_stack" "app_cdk" {

  github_enterprise {
    namespace = "ming-raf"
  }

  cloudformation {
    entry_template_file = "cdk.out/CdkStack.template.json"
    region              = "ap-southeast-2"
    template_bucket     = "spacelift-test"
    stack_name          = "app-cdk"
  }

  autodeploy     = true
  space_id       = data.spacelift_space_by_path.development.id
  branch         = "main"
  description    = "Typical CDK stack"
  name           = "CDK Application"
  project_root   = "cdk"
  repository     = "spacelift-test"
  runner_image   = "public.ecr.aws/s5n0e7e5/ming-spacelift:latest"
  worker_pool_id = spacelift_worker_pool.aws_ec2.id
  before_plan = [
    "npm install aws-cdk-lib",
    "cdk bootstrap",
    "cdk synth --output cdk/cdk.out",
    "cdk ls",
  ]
  labels = [ "infracost" ]
}

resource "spacelift_context_attachment" "app_cdk" {
  context_id = local.development_worker_pool_context_id
  stack_id   = spacelift_stack.app_cdk.id
  priority   = 0
}

resource "spacelift_drift_detection" "app_cdk" {
  reconcile = true
  stack_id  = spacelift_stack.app_cdk.id
  schedule  = ["*/1 * * * *"]
}

resource "spacelift_run" "app_cdk" {
  stack_id = spacelift_stack.app_cdk.id

  keepers = {
    branch = spacelift_stack.app_cdk.branch
  }
}

output "app_cdk_stack_id" {
  description = "app_cdk stack id"
  value       = spacelift_stack.app_cdk.id
}

# output "ec2_worker_pool_stack_id" {
#   description = "ec2_worker_pool stack id"
#   value       = spacelift_stack.ec2_worker_pool.id
# }
