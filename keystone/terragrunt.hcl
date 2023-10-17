terraform {
  source = "github.com/jadonn/terraform-juju-openstack-testing.git//keystone?ref=terragrunt"
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

dependency "vault" {
  config_path   = "../vault"

  mock_outputs  = {
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
  model = dependency.openstack_juju_model.outputs.name
  channel = include.global.locals.openstack_channel
  series = include.global.locals.series
  units = {
    keystone = 1
  }
  placement = {
    keystone = dependency.machines.outputs.machine_ids[2]
  }
  relation_names = {
    mysql_innodb_cluster = dependency.mysql.outputs.application_names.mysql_innodb_cluster
    vault = dependency.vault.outputs.application_names.vault
  }
}