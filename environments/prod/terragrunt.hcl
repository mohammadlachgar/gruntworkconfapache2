
locals {
  env = "prod"
}

include {
  path = find_in_parent_folders()
}