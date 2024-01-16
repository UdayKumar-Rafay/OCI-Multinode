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
variable "api_url" {
  description = "API URL for creating clusters"
}

variable "api_key" {
  description = "API key for authentication"
}

variable "num_clusters" {
  description = "Number of clusters to create"
}

resource "null_resource" "create_cluster_object" {
  provisioner "local-exec" {
    command = "bash -c './scale.sh -api_url=${var.api_url} -api_key=${var.api_key} -num_clusters=${var.num_clusters}'"
  }
}

resource "oci_core_instance" "worker" {
  depends_on = [null_resource.create_cluster_object]
  count             = var.worker_instance_count
  display_name      = "${var.worker_instance_display_name}-${count.index + 1}"
  compartment_id    = var.compartment_ocid
  availability_domain = var.availability_domain
  shape             = var.shape
  shape_config {
    memory_in_gbs = 8
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
    nsg_ids   = [var.network_security_group_id]
  }

  timeouts {
    create = "30m"
    update = "30m"
  }
}

resource "null_resource" "configure_instances" {
  count = var.worker_instance_count

  triggers = {
    instance_ids = element(oci_core_instance.worker[*].id, count.index)
  }

  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      ssh -i ${var.ssh_private_key_file} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${oci_core_instance.worker[count.index].public_ip} "sudo iptables -F && sudo iptables -t nat -F && sudo netfilter-persistent save && wget -q  -O  conjurer-linux-amd64.tar.bz2 ${var.conjurer_url}"
      sleep 5s
      # SCP the passphrase file to the remote instance
      LC_ALL=C scp -o StrictHostKeyChecking=no -i ${var.ssh_private_key_file} vyshak-mks-scale-1234-test${count.index + 1}_passphrase.txt ubuntu@${oci_core_instance.worker[count.index].public_ip}:/home/ubuntu/
      sleep 5s
      LC_ALL=C scp -o StrictHostKeyChecking=no -i ${var.ssh_private_key_file} vyshak-mks-scale-1234-test${count.index + 1}_cert.pem ubuntu@${oci_core_instance.worker[count.index].public_ip}:/home/ubuntu/
      sleep 5s
      ssh -i ${var.ssh_private_key_file} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${oci_core_instance.worker[count.index].public_ip} "tar -xjf conjurer-linux-amd64.tar.bz2 && sudo ./conjurer -m -edge-name=vyshak-mks-scale-1234-test${count.index + 1} -passphrase-file=vyshak-mks-scale-1234-test${count.index + 1}_passphrase.txt -creds-file=vyshak-mks-scale-1234-test${count.index + 1}_cert.pem"
    EOT
  }
  depends_on = [time_sleep.example]
}

resource "time_sleep" "example" {
  depends_on = [oci_core_instance.worker]

  create_duration = "60s"  # Sleep for 30 seconds
}

resource "time_sleep" "example2" {
  depends_on = [time_sleep.example]

  create_duration = "180s"  # Sleep for 30 seconds
}

resource "null_resource" "run_node_config_provision" {
  depends_on = [time_sleep.example2]

  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      sleep 1m
      bash -c './node_config_provision.sh -api_url=${var.api_url} -api_key=${var.api_key} -num_clusters=${var.num_clusters}'
    EOT
  }
}

