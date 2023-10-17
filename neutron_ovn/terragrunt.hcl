terraform {
  source = "github.com/jadonn/terraform-juju-openstack-testing.git//neutron_ovn?ref=terragrunt"
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

dependency "rabbitmq" {
  config_path = "../rabbitmq"

  mock_outputs = {
    application_names = {
      rabbitmq = "mock-rabbitmq"
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
    ovn = "22.03/stable"
  }
  series  = include.global.locals.series
  config = {
    central = {
      source = "distro"
    }
    chassis = {
      bridge-interface-mappings = "br-ex:ens3"
      ovn-bridge-mappings = "physnet1:br-ex"
    }
    neutron_api = {
      neutron-security-groups = "true"
      flat-network-providers = "physnet1"
      openstack-origin = include.global.locals.openstack_origin
    }
  }
  units = {
    central     = 3
    neutron_api = 1
  }

  placement = {
    central     = join(",", [for id in dependency.machines.outputs.machine_ids: "lxd:${id}"])
    neutron_api = "lxd:${dependency.machines.outputs.machine_ids[1]}"
  }
  relation_names = {
    keystone = dependency.keystone.outputs.application_names.keystone
    mysql_innodb_cluster = dependency.mysql.outputs.application_names.mysql_innodb_cluster
    rabbitmq = dependency.rabbitmq.outputs.application_names.rabbitmq
    vault = dependency.vault.outputs.application_names.vault
  }
}