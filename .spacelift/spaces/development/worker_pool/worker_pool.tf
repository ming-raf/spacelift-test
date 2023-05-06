
resource "spacelift_worker_pool" "aws-ec2" {
  name        = "AWS EC2 Worker Pool"
  csr         = filebase64("../../../spacelift.csr")
  description = "Used for all type jobs"
  space_id    = data.spacelift_space_by_path.development.id
}

variable "SPACELIFT_POOL_PRIVATE_KEY" {
  type = string
}

variable "worker_pool_security_groups" {
  type = list(string)
  default = [ "sg-0ad7cbb72cb29255d" ]
}

variable "worker_pool_subnets" {
  type = list(string)
  default = [ "subnet-06337061", "subnet-7c864124", "subnet-88b0cdc1" ]
}

module "my_workerpool" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-workerpool-on-ec2?ref=v1.5.0"

  configuration = <<-EOT
    export SPACELIFT_TOKEN="${spacelift_worker_pool.aws-ec2.config}"
    export SPACELIFT_POOL_PRIVATE_KEY="${var.SPACELIFT_POOL_PRIVATE_KEY}"
  EOT

  min_size          = 1
  max_size          = 5
  worker_pool_id    = spacelift_worker_pool.aws-ec2.id
  security_groups   = var.worker_pool_security_groups
  vpc_subnets       = var.worker_pool_subnets
}

output "worker_pool_id" {
  description = "Spacelift worker pool id"
  value       = spacelift_worker_pool.aws-ec2.id
}