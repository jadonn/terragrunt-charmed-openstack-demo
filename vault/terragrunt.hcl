terraform {
  source = "github.com/jadonn/terraform-juju-openstack-testing.git//vault?ref=terragrunt"
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

dependency "mysql" {
  config_path = "../mysql"

  mock_outputs = {
    application_names = {
      mysql_innodb_cluster = "mock-mysql-innodb-cluster"
    }
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
  model   = dependency.openstack_juju_model.outputs.name
  channel = "1.7/stable"
  config = {
    totally-unsecure-auto-unlock = "true"
    auto-generate-root-ca = "true"
  }
  units = 1
  placement = "lxd:${dependency.machines.outputs.machine_ids[0]}"
  relation_names = {
    mysql_innodb_cluster = dependency.mysql.outputs.application_names.mysql_innodb_cluster
  }
}