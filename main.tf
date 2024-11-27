terraform {
  required_version = ">= 0.13"
  required_providers {
    oci = {
      version = ">= 4.0.0"
      source  = "oracle/oci"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

locals {
  destroy_time = timestamp()
}


# Create the block volume

# resource "oci_core_volume" "my_volume" {
#   count                = var.worker_instance_count
#   availability_domain = var.availability_domain
#   compartment_id      = var.compartment_ocid
#   size_in_gbs         = 50  # Size of the volume in GBs
#  display_name         = "mks-${count.index + 1}"
# }

resource "oci_core_instance" "worker" {
 # depends_on = [null_resource.create_cluster_object]
  count             = var.worker_instance_count
  display_name      = "${var.worker_instance_display_name}-${count.index + 1}"
  compartment_id    = var.compartment_ocid
  availability_domain = var.availability_domain
  shape             = var.shape
  shape_config {
    memory_in_gbs = 4
    ocpus = 1
  }
  source_details {
    source_id   = var.source_ocid
    source_type = var.source_type
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_keys
  }

  create_vnic_details {
    subnet_id = var.subnet_id
    # nsg_ids   = [var.network_security_group_id]
  }

  timeouts {
    create = "30m"
    update = "30m"
  }
  # Ensure instance is in running state before proceeding
  provisioner "local-exec" {
    command = "echo 'Waiting for instance to be ready...' && sleep 120"
  }

}


# resource "oci_core_volume_attachment" "worker_volume_attachment" {
#   count              = var.worker_instance_count
#   instance_id        = oci_core_instance.worker[count.index].id
#   volume_id          = oci_core_volume.my_volume[count.index].id
#   attachment_type    = "paravirtualized"  

#   depends_on = [oci_core_instance.worker]  # Ensure instances are created before attaching volume

#   timeouts {
#     create = "30m"
#   }
# }



resource "null_resource" "configure_instances" {
  count = var.worker_instance_count

  triggers = {
    instance_ids = element(oci_core_instance.worker[*].id, count.index)
  }


  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      sleep 30s
      ssh -i ${var.ssh_private_key_file} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${oci_core_instance.worker[count.index].public_ip} "
      sudo iptables -F;
      sudo apt remove -yq iptables-persistent --purge;
      sudo apt install bzip2;
      "
    EOT
  }
  depends_on = [time_sleep.example]
}

resource "time_sleep" "example" {
  depends_on = [oci_core_instance.worker]

  create_duration = "60s"  # Sleep for 60 seconds
}



resource "null_resource" "clear_collected_configs" {
  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      if [ ! -z "${local.destroy_time}" ]; then
        echo "Clearing collected node configurations..."
        echo "[]" > /tmp/collected_node_configs.json
        python3 -c '
import ruamel.yaml
yaml = ruamel.yaml.YAML()
yaml.preserve_quotes = True
yaml.indent(mapping=2, sequence=4, offset=2)

config = {"nodes": []}
with open("/Users/uday/mks-scale/uday-nodes.yaml", "w") as f:
    yaml.dump(config, f)
'
      fi
    EOT
  }

  triggers = {
    destroy_time = "${timestamp()}"
  }
}


resource "null_resource" "configure_cluster" {
  depends_on = [null_resource.configure_instances]
  count = var.worker_instance_count

  triggers = {
    instance_id = oci_core_instance.worker[count.index].id
    instance_ip = oci_core_instance.worker[count.index].public_ip
  }

  provisioner "local-exec" {
    command = <<EOT
     #!/bin/bash
      sleep $((${count.index} * 1))  # Adjust sleep duration based on index
      python3 ./rctl_apply.py ${oci_core_instance.worker[count.index].display_name} ${oci_core_instance.worker[count.index].private_ip} ${oci_core_instance.worker[count.index].public_ip} ${var.ssh_private_key_file} ${count.index}
    EOT
  }
}

resource "null_resource" "finalize_yaml" {
  depends_on = [null_resource.configure_cluster]

  triggers = {
    last_configured_nodes = "${join(",", oci_core_instance.worker[*].id)}"
  }

  provisioner "local-exec" {
    command = <<EOT
     #!/bin/bash
      python3 ./finalise_yaml.py
    EOT
  }
}