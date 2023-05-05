terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
      version = "1.1.5"
    }
  }
}


provider "spacelift" {}

resource "spacelift_space" "staging" {
  name = "staging"

  # Every account has a root space that serves as the root for the space tree.
  # Except for the root space, all the other spaces must define their parents.
  parent_space_id = "root"
  inherit_entities = true

  # An optional description of a space.
  description = "This a child of the root space. It contains all the resources common to the staging infrastructure."
}