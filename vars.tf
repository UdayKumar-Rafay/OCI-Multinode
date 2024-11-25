variable "fingerprint" {
  description = "fingerprint of oci api private key"
  type        = string
}

variable "private_key_path" {
  description = "path to oci api private key used"
  type        = string
}

variable "region" {
  description = "the oci region where resources will be created"
  type        = string
}

variable "tenancy_ocid" {
  description = "tenancy ocid where to create the sources"
  type        = string
}

variable "user_ocid" {
  description = "ocid of user that terraform will use to create the resources"
  type        = string
}

variable "conjurer_url" {
  description = "conjurer url link"
  type        = string
}

variable "compartment_ocid" {
  description = "compartment ocid where to create all resources"
  type        = string
}

variable "freeform_tags" {
  description = "simple key-value pairs to tag the resources created using freeform tags."
  type        = map(string)
  default     = null
}

variable "defined_tags" {
  description = "predefined and scoped to a namespace to tag the resources created using defined tags."
  type        = map(string)
  default     = null
}

variable "instance_ad_number" {
  description = "The availability domain number of the instance. If none is provided, it will start with AD-1 and continue in round-robin."
  type        = number
  default     = 1
}

variable "cp_instance_count" {
  description = "Number of identical control plane instances to launch from a single module."
  type        = number
  default     = 1
}

variable "worker_instance_count" {
  description = "Number of identical worker node instances to launch from a single module."
  type        = number
  default     = 1
}


variable "cp_instance_display_name" {
  description = "(Updatable) A user-friendly name for the instance. Does not have to be unique, and it's changeable."
  type        = string
  default     = "vyshak-scale-inst"
}

variable "worker_instance_display_name" {
  description = "(Updatable) A user-friendly name for the instance. Does not have to be unique, and it's changeable."
  type        = string
  default     = "vyshak-scale-inst"
}

variable "cp_node_memory_in_gbs" {
  type        = number
  description = "(Updatable) The total amount of memory available to the instance, in gigabytes."
  default     = null
}

variable "cp_node_ocpus" {
  type        = number
  description = "(Updatable) The total number of OCPUs available to the instance."
  default     = null
}

variable "worker_node_memory_in_gbs" {
  type        = number
  description = "(Updatable) The total amount of memory available to the instance, in gigabytes."
  default     = null
}

variable "worker_node_ocpus" {
  type        = number
  description = "(Updatable) The total number of OCPUs available to the instance."
  default     = null
}

variable "instance_state" {
  type        = string
  description = "(Updatable) The target state for the instance. Could be set to RUNNING or STOPPED."
  default     = "RUNNING"

  validation {
    condition     = contains(["RUNNING", "STOPPED"], var.instance_state)
    error_message = "Accepted values are RUNNING or STOPPED."
  }
}

variable "shape" {
  description = "The shape of an instance."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "baseline_ocpu_utilization" {
  description = "(Updatable) The baseline OCPU utilization for a subcore burstable VM instance"
  type        = string
  default     = "BASELINE_1_1"
}

variable "source_ocid" {
  description = "The OCID of an image or a boot volume to use, depending on the value of source_type."
  type        = string
}

variable "source_type" {
  description = "The source type for the instance."
  type        = string
  default     = "image"
}


variable "ssh_authorized_keys" {
  #! Deprecation notice: Please use `ssh_public_keys` instead
  description = "DEPRECATED: use ssh_public_keys instead. Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance."
  type        = string
  default     = null
}

variable "ssh_public_keys" {
  description = "Public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on the instance. To provide multiple keys, see docs/instance_ssh_keys.adoc."
  type        = string
  default     = null
}

variable "availability_domain" {
  description = "Public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on the instance. To provide multiple keys, see docs/instance_ssh_keys.adoc."
  type        = string
  default     = null
}

variable "public_ip" {
  description = "Whether to create a Public IP to attach to primary vnic and which lifetime. Valid values are NONE, RESERVED or EPHEMERAL."
  type        = string
  default     = "NONE"
}


variable "boot_volume_backup_policy" {
  description = "Choose between default backup policies : gold, silver, bronze. Use disabled to affect no backup policy on the Boot Volume."
  type        = string
  default     = "disabled"
}

variable "block_storage_sizes_in_gbs" {
  description = "Sizes of volumes to create and attach to each instance."
  type        = list(string)
  default     = [50]
}

variable "network_security_group_id" {
  type        = string
}

variable "subnet_id" {
  type        = string
}

variable "ssh_username" {
  type        = string
  default     = "ubuntu"
}


variable "ssh_private_key_file" {
  type        = string
}

variable "private_key_password" {
  type        = string
}

variable "volume_count" {
  description = "Number of volumes to create"
  type        = number
  default     = 3
}


variable "new_worker_instance_count" {
  description = "Number of new worker instances to create"
  type        = number
  default     = 3
}