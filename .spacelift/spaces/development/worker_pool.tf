
resource "spacelift_worker_pool" "aws_ec2" {
  name        = "AWS EC2 Worker Pool (Development)"
  csr         = filebase64("../../spacelift.csr")
  description = "Used for all type jobs"
  space_id    = data.spacelift_space_by_path.development.id
}

variable "SPACELIFT_POOL_PRIVATE_KEY" {
  type = string
  sensitive = true
}

module "my_workerpool" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-workerpool-on-ec2?ref=v1.5.0"

  configuration = <<-EOT
    export SPACELIFT_TOKEN="${spacelift_worker_pool.aws_ec2.config}"
    export SPACELIFT_POOL_PRIVATE_KEY="${var.SPACELIFT_POOL_PRIVATE_KEY}"
  EOT

  min_size          = 1
  max_size          = 5
  worker_pool_id    = spacelift_worker_pool.aws_ec2.id
  security_groups   = [ aws_security_group.open_sg.id ]
  vpc_subnets       = [ aws_subnet.private_subnet.id ]
}

output "worker_pool_id" {
  value = spacelift_worker_pool.aws_ec2.id
}