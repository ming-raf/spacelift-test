variable "dev_admin_stack_name" {
  type = string
}

variable "entry_template_file" {
  type = string
}

variable "cfn_stack_name" {
  type = string
}

variable "name" {
  type = string
}

variable "project_root" {
  type = string
}

variable "repository" {
  type = string
}

variable "worker_pool_id" {
  type = string
  default = "01H0AYQ6M69AC4JB36KWA2TJTF"
}

variable "spacelift_aws_integrations_id" {
  type = string
  default = "01H0AYQ884Q5B7HK4992P48R0X"
}
