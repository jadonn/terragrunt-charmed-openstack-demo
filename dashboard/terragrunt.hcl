terraform {
  source = "github.com/jadonn/terraform-juju-openstack-testing.git//dashboard?ref=terragrunt"
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

dependency "keystone" {
  config_path = "../keystone"

  mock_outputs = {
    application_names = {
      keystone = "mock-keystone"
    }
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
dependency "vault" {
  config_path = "../vault"

  mock_outputs = {
    application_names = {
      vault = "mock-vault"
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
  channel = {
    openstack = include.global.locals.openstack_channel
    mysql = include.global.locals.mysql_channel
  }
  series = include.global.locals.series
  units = {
    dashboard = 1
  }
  placement = {
    dashboard = "lxd:${dependency.machines.outputs.machine_ids[0]}"
  }
  relation_names = {
    keystone  = dependency.keystone.outputs.application_names.keystone
    mysql_innodb_cluster = dependency.mysql.outputs.application_names.mysql_innodb_cluster
    vault = dependency.vault.outputs.application_names.vault
  }
}