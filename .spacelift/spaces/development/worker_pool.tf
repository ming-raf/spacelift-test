
resource "spacelift_worker_pool" "aws_ec2" {
  name        = "AWS EC2 Worker Pool (Development)"
  csr         = filebase64("../../spacelift.csr")
  description = "Used for all type jobs"
  space_id    = data.spacelift_space_by_path.development.id
}

data "spacelift_environment_variable" "private_key" {
  context_id = local.development_worker_pool_context_id
  name       = "TF_VAR_SPACELIFT_POOL_PRIVATE_KEY"
  depends_on = [ spacelift_context_attachment.worker_pool_worker_pool ]
}

module "my_workerpool" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-workerpool-on-ec2?ref=v1.5.0"

  configuration = <<-EOT
    export SPACELIFT_TOKEN="${spacelift_worker_pool.aws_ec2.config}"
    export SPACELIFT_POOL_PRIVATE_KEY="${base64encode(data.spacelift_environment_variable.private_key.value)}"
  EOT

  min_size          = 1
  max_size          = 5
  worker_pool_id    = spacelift_worker_pool.aws_ec2.id
  security_groups   = [ aws_security_group.open_sg.id ]
  vpc_subnets       = [ aws_subnet.private_subnet.id ]
  depends_on = [ data.spacelift_environment_variable.private_key ]
}
