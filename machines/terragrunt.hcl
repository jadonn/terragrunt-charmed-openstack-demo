terraform {
  source = "github.com/jadonn/terraform-juju-openstack-testing.git//machines?ref=terragrunt"
}

dependency "openstack_juju_model" {
  config_path = "../openstack_juju_model"

  mock_outputs = {
    name = "mock-juju-model-name"
  }
  mock_outputs_allowed_terraform_commands = ["validate"]
}

include "root" {
  path = find_in_parent_folders()
}

include "global" {
  path    = find_in_parent_folders("global.hcl")
  expose  = true
}

inputs = {
  model         = dependency.openstack_juju_model.outputs.name
  series        = include.global.locals.series
  name_prefix   = "terragrunt"
  constraints   = "tags=hyperconverged"
  machine_count = 3
}
