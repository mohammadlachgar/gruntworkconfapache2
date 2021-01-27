
locals {
  env = "prod"
}

inputs = {
  env  = local.env
}

include {
  path = find_in_parent_folders()
}