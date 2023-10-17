terraform {
  source = "github.com/jadonn/terraform-juju-openstack-testing.git//placement?ref=terragrunt"
}

dependency "openstack_juju_model" {
  config_path = "../openstack_juju_model"

  mock_outputs = {
    name = "mock-juju-model-name"
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

dependency "keystone" {
  config_path = "../keystone"

  mock_outputs = {
    application_names = {
      keystone = "mock-keystone"
    }
  }

  mock_outputs_allowed_terraform_commands = ["validate"]
}

dependency "mysql" {
  config_path = "../mysql"

  mock_outputs = {
    application_names = {
      mysql_innodb_cluster = "mock-mysql-innodb-cluster"
    }
  }

  mock_outputs_allowed_terraform_commands = ["validate"]
}

dependency "nova" {
  config_path = "../nova"
  mock_outputs = {
    application_names = {
      compute = "mock-nova-compute"
      cloud_controller = "mock-nova-cloud-controller"
    }
  }
  
  mock_outputs_allowed_terraform_commands = ["validate"]
}

dependency "vault" {
  config_path = "../vault"

  mock_outputs = {
    application_names = {
      vault = "mock-vault"
    }
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
  channel = {
    openstack = include.global.locals.openstack_channel
    mysql = include.global.locals.mysql_channel
  }
  series = include.global.locals.series
  units = {
    placement = 1
  }
  placement = {
    placement = "lxd:${dependency.machines.outputs.machine_ids[2]}"
  }
  relation_names = {
    keystone  = dependency.keystone.outputs.application_names.keystone
    mysql_innodb_cluster = dependency.mysql.outputs.application_names.mysql_innodb_cluster
    nova_cloud_controller = dependency.nova.outputs.application_names.cloud_controller
    vault = dependency.vault.outputs.application_names.vault
  }
}