terraform {
  source = "git@github.com:jadonn/terraform-juju-openstack-testing.git//ceph?ref=terragrunt"
}

dependency "openstack_juju_model" {
  config_path = "../openstack_juju_model"

  mock_outputs = {
    name = "mock-juju-model-name"
  }
  mock_outputs_allowed_terraform_commands = ["validate"]
}

dependency "nova" {
  config_path = "../nova"

  mock_outputs = {
    application_names = {
      compute           = "mock-nova-compute"
      cloud_controller  = "mock-nova-cloud-controller"
    }
  }

  mock_outputs_allowed_terraform_commands = ["validate"]
}

dependency "machines" {
  config_path = "../machines"
  mock_outputs = {
    machine_ids = ["0", "1", "2"]
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
  model   = dependency.openstack_juju_model.outputs.name
  channel = "quincy/stable"
  series  = include.global.locals.series
  config  = {
    osds    = {
      osd-devices = "/dev/vdb"
      source      = "distro"
    }
    mons    = {}
    rgw     = {}
  }
  units = {
    osds  = 3
    mons  = 3
    rgw   = 1
  }
  placement = {
    osds  = join(",", dependency.machines.outputs.machine_ids)
    mons  = join(",", [for id in dependency.machines.outputs.machine_ids: "lxd:${id}"])
    rgw   = "lxd:${dependency.machines.outputs.machine_ids[1]}"
  }
}