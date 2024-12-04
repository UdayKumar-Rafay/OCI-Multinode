# OCI Multi-Node Creation Documentation

## Method 1: Using Terraform (Original Method)

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

## Method 2: Using Python Script (Alternative Method)

### Prerequisites

1. Python 3.6+ and required packages:
```bash
pip3 install oci paramiko pyyaml python-dotenv
```

2. OCI CLI configuration and authentication

### Configuration Setup

1. Edit the configuration in `oci_node_manager.py`. Update the following values in the `.env` file:
```python
# .env.example
   USER_OCID=your-user-ocid
   FINGERPRINT=your-api-key-fingerprint
   KEY_FILE_PATH=/path/to/your/oci_private_key.pem
   SSH_PUBLIC_KEY_PATH=/path/to/your/id_rsa.pub
   SSH_PRIVATE_KEY_PATH=/path/to/your/id_rsa
```

2. Make the script executable:
```bash
chmod +x oci_node_manager.py
```

### Usage

#### Deploy Nodes
- Deploy a single node: #default name is "rafay-paas"
  ```bash
  ./oci_node_manager.py deploy --count 1
  ```

- Deploy multiple nodes:
  ```bash
  ./oci_node_manager.py deploy --count 5
  ```

- Deploy with custom instance naming:
  ```bash
  ./oci_node_manager.py deploy --count 3 --basename custom-worker
  # Creates: custom-worker-1, custom-worker-2, custom-worker-3
  ```

- Deploy with custom concurrency:
  ```bash
  ./oci_node_manager.py deploy --count 10 --concurrent 8
  ```

- Combine multiple flags:
  ```bash
  ./oci_node_manager.py deploy --count 5 --basename prod-node --concurrent 3
  ```

### Available Deployment Flags
| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `--count` | Number of nodes to deploy | 1 | `--count 5` |
| `--basename` | Base name for instance naming | rafay-paas | `--basename worker` |
| `--concurrent` | Maximum concurrent operations | 5 | `--concurrent 8` |

### Node Naming
- Nodes are automatically numbered sequentially
- Numbering continues from the last used index in nodes.yaml
- Example sequence with `--basename rafay-paas`:
  - First deployment: rafay-paas-1, rafay-paas-2, rafay-paas-3
  - Second deployment: rafay-paas-4, rafay-paas-5, rafay-paas-6

#### Manage Nodes by Hostname
- Stop specific nodes by hostname:
  ```bash
  ./oci_node_manager.py stop --hostnames rafay-paas-1 rafay-paas-2
  ```

- Start specific nodes by hostname:
  ```bash
  ./oci_node_manager.py start --hostnames rafay-paas-1 rafay-paas-2
  ```

- Destroy specific nodes by hostname:
  ```bash
  ./oci_node_manager.py destroy --hostnames rafay-paas-1 rafay-paas-2
  ```

#### Destroy Nodes
- Destroy all deployed nodes:
  ```bash
  ./oci_node_manager.py destroy
  ```

- Destroy specific nodes by hostname:
  ```bash
  ./oci_node_manager.py destroy --hostnames rafay-paas-1 rafay-paas-2
  ```

- Destroy with custom concurrency:
  ```bash
  ./oci_node_manager.py destroy --concurrent 8
  ```

- Combine multiple flags:
  ```bash
  ./oci_node_manager.py destroy --hostnames rafay-paas-1 rafay-paas-2 --concurrent 3
  ```

### Available Destroy Flags
| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `--hostnames` | Specific nodes to destroy | None (destroys all) | `--hostnames worker-1 worker-2` |
| `--concurrent` | Maximum concurrent operations | 5 | `--concurrent 8` |

### Features
- Concurrent node creation and deletion
- Automatic YAML configuration generation
- Progress tracking and detailed feedback
- Error handling and recovery
- Configurable concurrency limits
- Manage nodes by hostname for easier identification

### Generated Files
- `nodes.yaml`: Contains node configuration details
- `instance_ids.txt`: Backup of instance IDs for tracking

### Important Notes
- The script uses the VM.Standard.E4.Flex shape with 1 OCPU and 4GB RAM by default
- Instances are named as "rafay-paas-1", "rafay-paas-2", etc.
- The script automatically configures iptables rules on the instances
- Maximum concurrent operations can be adjusted using the `--concurrent` flag
- Default concurrency is set to 5 to respect API rate limits

### Troubleshooting
1. If deployment fails:
   - Check OCI credentials and permissions
   - Verify subnet and image OCIDs
   - Ensure SSH keys are properly configured

2. If destroy operation fails:
   - Check if instances still exist in OCI console
   - Verify the YAML file and instance_ids.txt are present
   - Ensure OCI API access is working

### Comparison with Terraform Method
Advantages:
- Faster concurrent operations
- Real-time progress feedback
- Simpler configuration
- Direct OCI API interaction

Disadvantages:
- Less infrastructure-as-code features
- Manual state management
- Limited to specific use case

Choose the method that best suits your needs:
- Use Terraform method for infrastructure-as-code approach
- Use Python script for quick deployments and better concurrency

## Setup

1. Copy the `.env.example` file to `.env`:

   ```bash
   cp .env.example .env
   ```

2. Fill in the `.env` file with your actual configuration values.
