
  terraform {
    extra_arguments "parent-configs" {
      arguments = [
        "-var-file=${get_terragrunt_dir()}/terraform.tfvars",
        "-var-file=./terraform.tfvars"
      ]
      commands = [
        "apply",
        "plan",
        "import",
        "push",
        "refresh"
      ]
    }
  }


remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "project_id-tfstate"
    prefix = path_relative_to_include()
  }
}


generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "google" {
  credentials = file("../../creds/serviceaccount.json")
  project = var.project
}
EOF
}

generate "callmodules" {
  path = "callmodules.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF


module "vpc" {
  source  = "../../modules/vpc"
  project = var.project
  env     = var.env
}

module "http_server" {
  source  = "../../modules/http_server"
  project = var.project
  subnet  = module.vpc.subnet
}

module "firewall" {
  source  = "../../modules/firewall"
  project = var.project
  subnet  = module.vpc.subnet
}
EOF
}

generate "outputs" {
  path = "outputs.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
output "network" {
  value = module.vpc.network
}

output "subnet" {
  value = module.vpc.subnet
}

output "firewall_rule" {
  value = module.firewall.firewall_rule
}

output "instance_name" {
  value = module.http_server.instance_name
}

output "external_ip" {
  value = module.http_server.external_ip
}
EOF
}

generate "variables" {
  path = "variables.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
variable "project" {}
variable "env" {}
EOF
}

generate "versions" {
  path = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_version = "~> 0.14.5"
}
EOF
}