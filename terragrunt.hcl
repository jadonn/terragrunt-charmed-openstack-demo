generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_providers {
    juju = {
      version = "~> 0.8.0"
      source = "juju/juju"
    }
  }
}

provider "juju" {
}
EOF
}