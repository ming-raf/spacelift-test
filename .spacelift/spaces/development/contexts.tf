resource "spacelift_context" "spacelift-worker-pool" {
  description = "Configuration for Spacelift worker pool (development)"
  name        = "Development Worker Pool"
  space_id    = data.spacelift_space_by_path.development.id
}

resource "spacelift_context_attachment" "worker_pool_worker_pool" {
  context_id = spacelift_context.spacelift-worker-pool.id
  stack_id   = spacelift_stack.ec2_worker_pool.id
  priority   = 0
}

output "spacelift_context_id" {
  description = "Spacelift context id"
  value       = spacelift_context.spacelift-worker-pool.id
}
