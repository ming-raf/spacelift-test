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
  before_init = [ "curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh" ]
  before_plan = [
    "npm install aws-cdk-lib",
    "cdk bootstrap",
    "cdk synth --output cdk/cdk.out",
    "cdk ls",
  ]
  labels = [ "infracost" ]
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


resource "spacelift_stack" "lambda_cf" {

  github_enterprise {
    namespace = "ming-raf"
  }

  cloudformation {
    entry_template_file = "cloudformation/lambda.yml"
    region              = "ap-southeast-2"
    template_bucket     = "spacelift-test"
    stack_name          = "Lambda-Test"
  }

  autodeploy     = true
  space_id       = data.spacelift_space_by_path.development.id
  branch         = "main"
  name           = "Lambda CloudFormation"
  repository     = "spacelift-test"
  labels = [ "infracost" ]
}

resource "spacelift_stack" "lambda_terraform" {

  github_enterprise {
    namespace = "ming-raf"
  }

  autodeploy     = true
  space_id       = data.spacelift_space_by_path.development.id
  branch         = "main"
  name           = "Lambda Terraform"
  repository     = "spacelift-test"
  project_root = "terraform"
  labels = [ "infracost" ]
}

resource "spacelift_drift_detection" "lambda_terraform" {
  reconcile = true
  stack_id  = spacelift_stack.lambda_terraform.id
  schedule  = ["*/1 * * * *"]
}

output "app_cdk_stack_id" {
  description = "app_cdk stack id"
  value       = spacelift_stack.app_cdk.id
}