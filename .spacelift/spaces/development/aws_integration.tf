data "aws_caller_identity" "current" {}

locals {
  role_name = "Spacelift-Development-Role"
  role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.role_name}"
}

resource "spacelift_aws_integration" "this" {
  name = local.role_name

  # We need to set this manually rather than referencing the role to avoid a circular dependency
  space_id                       = data.spacelift_space_by_path.development.id
  role_arn                       = local.role_arn
  generate_credentials_in_worker = false
}

resource "aws_iam_role" "this" {
  name = local.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      jsondecode(data.spacelift_aws_integration_attachment_external_id.this.assume_role_policy_statement),
      jsondecode(data.spacelift_aws_integration_attachment_external_id.lambda_cf.assume_role_policy_statement),
      jsondecode(data.spacelift_aws_integration_attachment_external_id.lambda_terraform.assume_role_policy_statement),
      jsondecode(data.spacelift_aws_integration_attachment_external_id.cdk-stack-2.assume_role_policy_statement),
      jsondecode(data.spacelift_aws_integration_attachment_external_id.cdk-stack-3.assume_role_policy_statement)
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "administrator" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.this.name
}

# The spacelift_aws_integration_attachment_external_id data source is used to help generate a trust policy for the integration
data "spacelift_aws_integration_attachment_external_id" "this" {
  integration_id = spacelift_aws_integration.this.id
  stack_id       = spacelift_stack.app_cdk.id
  read           = true
  write          = true
}

resource "spacelift_aws_integration_attachment" "this" {
  integration_id = spacelift_aws_integration.this.id
  stack_id       = spacelift_stack.app_cdk.id
  read           = true
  write          = true

  # The role needs to exist before we attach since we test role assumption during attachment.
  depends_on = [
    aws_iam_role.this
  ]
}

data "spacelift_aws_integration_attachment_external_id" "lambda_cf" {
  integration_id = spacelift_aws_integration.this.id
  stack_id       = spacelift_stack.lambda_cf.id
  read           = true
  write          = true
}

resource "spacelift_aws_integration_attachment" "lambda_cf" {
  integration_id = spacelift_aws_integration.this.id
  stack_id       = spacelift_stack.lambda_cf.id
  read           = true
  write          = true

  depends_on = [
    aws_iam_role.this
  ]
}

data "spacelift_aws_integration_attachment_external_id" "lambda_terraform" {
  integration_id = spacelift_aws_integration.this.id
  stack_id       = spacelift_stack.lambda_terraform.id
  read           = true
  write          = true
}

resource "spacelift_aws_integration_attachment" "lambda_terraform" {
  integration_id = spacelift_aws_integration.this.id
  stack_id       = spacelift_stack.lambda_terraform.id
  read           = true
  write          = true

  depends_on = [
    aws_iam_role.this
  ]
}

output "spacelift_aws_integrations_id" {
  value = spacelift_aws_integration.this.id
}