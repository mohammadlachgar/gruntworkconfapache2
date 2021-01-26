locals {
  env = "dev"
}

include {
  path = find_in_parent_folders()
}