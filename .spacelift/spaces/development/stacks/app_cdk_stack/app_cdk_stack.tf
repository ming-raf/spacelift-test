data "spacelift_space_by_path" "development" {
  space_path = "root/development"
}

resource "spacelift_stack" "app_cdk" {

  github_enterprise {
    namespace = "ming-raf"
  }

  cloudformation {
    entry_template_file = "cdk.out/CdkStack.template.json"
    region              = "ap-southeast-2"
    template_bucket     = "s3://spacelift-test"
    stack_name          = "app-cdk"
  }

  autodeploy   = true
  space_id     = data.spacelift_space_by_path.development.id
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

output "app_cdk_stack_id" {
  description = "app_cdk stack id"
  value       = spacelift_stack.app_cdk.id
}


