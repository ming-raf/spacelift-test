resource "spacelift_context" "spacelift-worker-pool" {
  description = "Configuration for Spacelift worker pool (development)"
  name        = "Development Worker Pool"
  space_id    = data.spacelift_space_by_path.development.id
}

resource "spacelift_context_attachment" "attachment" {
  context_id = spacelift_context.spacelift-worker-pool.id
  stack_id   = module.stacks.app_cdk_stack_id
  priority   = 0
}

output "spacelift_context_id" {
  description = "Spacelift context id"
  value       = spacelift_context.spacelift-worker-pool.id
}
