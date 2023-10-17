terraform {
  source = "github.com/jadonn/terraform-juju-openstack-testing.git//nova?ref=terragrunt"
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

dependency "neutron_ovn" {
  config_path = "../neutron_ovn"

  mock_outputs = {
    application_names = {
      neutron_api = "mock-neutron-api"
      ovn_chassis = "mock-ovn-chassis"
    }
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "rabbitmq" {
  config_path = "../rabbitmq"

  mock_outputs = {
    application_names = {
      rabbitmq = "mock-rabbitmq"
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
  channel = include.global.locals.openstack_channel
  series  = include.global.locals.series
  mysql = {
    channel = include.global.locals.mysql_channel
  }
  config  = {
    compute           = {
      config-flags          = "default_ephemeral_format=ext4"
      enable-live-migration = "true"
      enable-resize         = "true"
      migration-auth-type   = "ssh"
      virt-type             = "qemu"
    }
    cloud_controller  = {
      network-manager       = "Neutron"
      openstack-origin      = include.global.locals.openstack_origin
    }
  }
  units = {
    compute           = 3
    cloud_controller  = 1
  }
  placement = {
    compute           = join(",", dependency.machines.outputs.machine_ids)
    cloud_controller  = "lxd:${dependency.machines.outputs.machine_ids[1]}"
  }
  relation_names = {
    keystone = dependency.keystone.outputs.application_names.keystone
    mysql_innodb_cluster = dependency.mysql.outputs.application_names.mysql_innodb_cluster
    neutron_api = dependency.neutron_ovn.outputs.application_names.neutron_api
    ovn_chassis = dependency.neutron_ovn.outputs.application_names.ovn_chassis
    rabbitmq = dependency.rabbitmq.outputs.application_names.rabbitmq
    vault = dependency.vault.outputs.application_names.vault
  }
}