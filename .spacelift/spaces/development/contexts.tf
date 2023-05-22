variable "spacelift_stack_id" {
  type = string
}

locals {
  development_worker_pool_context_id = "manual"
}

resource "spacelift_context_attachment" "worker_pool_worker_pool" {
  context_id = local.development_worker_pool_context_id
  stack_id   = var.spacelift_stack_id
  priority   = 0
}

resource "spacelift_context_attachment" "app_cdk" {
  context_id = local.development_worker_pool_context_id
  stack_id   = spacelift_stack.app_cdk.id
  priority   = 0
}

resource "spacelift_context_attachment" "lambda_cf_dev" {
  context_id = local.development_worker_pool_context_id
  stack_id   = spacelift_stack.lambda_cf.id
  priority   = 0
}

resource "spacelift_context_attachment" "lambda_terraform_dev" {
  context_id = local.development_worker_pool_context_id
  stack_id   = spacelift_stack.lambda_terraform.id
  priority   = 0
}

resource "spacelift_context" "capability" {
  name     = "IAM Capability"
  space_id = data.spacelift_space_by_path.development.id
}

resource "spacelift_context_attachment" "app_cdk_capability" {
  context_id = spacelift_context.capability.id
  stack_id   = spacelift_stack.app_cdk.id
  priority   = 0
}

resource "spacelift_context_attachment" "lambda_cf" {
  context_id = spacelift_context.capability.id
  stack_id   = spacelift_stack.lambda_cf.id
  priority   = 0
}

resource "spacelift_context_attachment" "lambda_terraform" {
  context_id = spacelift_context.capability.id
  stack_id   = spacelift_stack.lambda_terraform.id
  priority   = 0
}

resource "spacelift_context_attachment" "lambda_terraform_2" {
  context_id = spacelift_context.capability.id
  stack_id   = spacelift_stack.lambda_terraform_2.id
  priority   = 0
}

resource "spacelift_environment_variable" "capability_iam" {
  context_id = spacelift_context.capability.id
  name       = "CF_CAPABILITY_IAM"
  value      = "1"
  write_only = false
}

resource "spacelift_environment_variable" "capability_named_iam" {
  context_id = spacelift_context.capability.id
  name       = "CF_CAPABILITY_NAMED_IAM"
  value      = "1"
  write_only = false
}
