terraform {
  source = "github.com/jadonn/terraform-juju-openstack-testing.git//mysql?ref=terragrunt"
}

dependency "openstack_juju_model" {
  config_path = "../openstack_juju_model"

  mock_outputs = {
    name = "mock-juju-model-name"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "machines" {
  config_path = "../machines"

  mock_outputs = {
    machine_ids = ["0", "1", "2"]
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

include "root" {
  path = find_in_parent_folders()
}

include "global" {
  path    = find_in_parent_folders("global.hcl")
  expose  = true
}

inputs = {
  model = dependency.openstack_juju_model.outputs.name
  channel = include.global.locals.mysql_channel
  series = include.global.locals.series
  units = 3
  placement = join(",", dependency.machines.outputs.machine_ids)
}