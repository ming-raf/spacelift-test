variable "spacelift_stack_id" {
  type = string
}

locals {
  development_worker_pool_id = "development-worker-pool-manual"
}

resource "spacelift_context_attachment" "worker_pool_worker_pool" {
  context_id = local.development_worker_pool_id
  stack_id   = var.spacelift_stack_id
  priority   = 0
}
