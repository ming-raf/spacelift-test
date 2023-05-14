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

resource "spacelift_context" "lambda_cf" {
  name        = "Lambda CloudFormation"
}

resource "spacelift_context_attachment" "lambda_cf" {
  context_id = spacelift_context.lambda_cf.id
  stack_id = spacelift_stack.lambda_cf.id
  priority   = 0
}

resource "spacelift_environment_variable" "capability_iam" {
  context_id   = spacelift_context.lambda_cf.id
  name       = "CF_CAPABILITY_IAM"
  value      = "1"
  write_only = false
}