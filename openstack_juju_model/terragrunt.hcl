terraform {
  source = "github.com/jadonn/terraform-juju-openstack-testing.git//openstack_juju_model?ref=terragrunt"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  name  = "terragrunt-ovb"
  cloud = {
    name    = "maas-ovb"
    region  = "default"
  }
}
