
# OCI Multi-Node Creation Documentation

## Prerequisites

### Required Packages
1. Python packages: 
```bash
# Install required Python packages
pip3 install ruamel.yaml
```

2. Terraform (latest version)
3. OCI CLI (latest version)

### SSH Key Generation
Generate SSH keys without a passphrase (required for automated deployment):
```bash
# Generate SSH key pair without passphrase
ssh-keygen -t rsa -b 4096 -C "your.email@rafay.co"
```

### Configuration Setup

1. Create a file to store node details:
```bash
# Create nodes configuration file
touch /path/to/your/nodes.yaml

# Initial content should be:
nodes: []
```

2. Update the following paths in your configuration files:
```bash
# In finalise_yaml.py
cluster_config_file = "/path/to/your/nodes.yaml"

# In main.tf
python3 -c "... /path/to/your/nodes.yaml ..." #at line 128
```

3. Update the following variables in `terraform.tfvars`:
```hcl
# Instance naming
worker_instance_display_name = "your-worker-name"

# OCI Authentication
user_ocid        = "ocid1.user.oc1..your-user-ocid"
private_key_path = "/path/to/your/.oci/oci_private_key.pem"
fingerprint      = "your:oci:api:key:fingerprint"

# SSH Configuration
ssh_public_keys = <<EOT
your-ssh-public-key-content
EOT

ssh_private_key_file = "/path/to/your/.ssh/id_rsa"
```


## Usage

1. Make the deployment script executable:
```bash
chmod +x create-nodes.sh
```

2. Run the script:
```bash
./create-nodes.sh
```

3. Choose from the menu:
    - Option 1: Deploy worker nodes
   - Option 2: Destroy infrastructure
   - Option 3: Exit

4. For deployment:
   - Enter the number of worker nodes when prompted
   - Review the terraform plan
   - Confirm to apply

5. For destruction:
   - Confirm destruction
   - Wait for completion

## Important Notes
- Ensure all paths in configuration files are absolute paths
- SSH keys must be generated without a passphrase
- The nodes.yaml file must exist and be writable
- Ensure proper OCI permissions for resource creation/destruction

