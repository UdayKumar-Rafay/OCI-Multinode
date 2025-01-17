#!/usr/bin/env python3
from dotenv import load_dotenv
import oci
import os
import time
import yaml
import paramiko
import argparse
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime

class OCINodeManager:
    def __init__(self):
        # Load environment variables from .env file
        load_dotenv()
        # OCI Configuration
        self.config = {
            "tenancy": "ocid1.tenancy.oc1..aaaaaaaaaa3ghjcqbrbzmssbzhxzhxf24rpmuyxbaxwcj2axwoqkpd56ljkq",
            "user": os.getenv("USER_OCID"),
            "fingerprint": os.getenv("FINGERPRINT"),
            "key_file": os.getenv("KEY_FILE_PATH"),
            "region": "us-phoenix-1",
            "compartment_id": "ocid1.tenancy.oc1..aaaaaaaaaa3ghjcqbrbzmssbzhxzhxf24rpmuyxbaxwcj2axwoqkpd56ljkq",
            "availability_domain": "PaOl:PHX-AD-3",
            "subnet_id": "ocid1.subnet.oc1.phx.aaaaaaaay3bdnbnek22wxpjwn5fwli6kpfmi3n2dtj5soexyflcaievm4ogq",
            "image_id": "ocid1.image.oc1.phx.aaaaaaaaualravz5pufpmyzqevsrmqjmcwjmep3gddvai6dgzvgd7ku7ovyq",
            "ssh_public_key_path": os.getenv("SSH_PUBLIC_KEY_PATH"),
            "ssh_private_key_path": os.getenv("SSH_PRIVATE_KEY_PATH")
        }
        
        self.yaml_file = "nodes.yaml"
        
        # Create proper OCI config dictionary
        self.oci_config = {
            "tenancy": self.config["tenancy"],
            "user": self.config["user"],
            "fingerprint": self.config["fingerprint"],
            "key_file": self.config["key_file"],
            "region": self.config["region"]
        }
        
        # Initialize clients with our config
        self.compute_client = oci.core.ComputeClient(self.oci_config)
        self.network_client = oci.core.VirtualNetworkClient(self.oci_config)

        self.max_workers = 10  # Maximum concurrent operations

    def create_instance(self, display_name):
        """Create an OCI instance"""
        instance_details = oci.core.models.LaunchInstanceDetails(
            availability_domain=self.config["availability_domain"],
            compartment_id=self.config["compartment_id"],
            shape="VM.Standard.E4.Flex",
            shape_config=oci.core.models.LaunchInstanceShapeConfigDetails(
<<<<<<< HEAD
                ocpus=1,
                memory_in_gbs=4
=======
                ocpus=4,
                memory_in_gbs=16
>>>>>>> 574671c (added a missing comma to install the bzip2)
            ),
            display_name=display_name,
            source_details=oci.core.models.InstanceSourceViaImageDetails(
                source_type="image",
                image_id=self.config["image_id"]
            ),
            create_vnic_details=oci.core.models.CreateVnicDetails(
                subnet_id=self.config["subnet_id"],
                assign_public_ip=True
            ),
            metadata={
                "ssh_authorized_keys": Path(self.config["ssh_public_key_path"]).read_text()
            }
        )

        instance = self.compute_client.launch_instance(instance_details)
        return instance.data

    def wait_for_instance_ready(self, instance_id):
        """Wait for instance to be running and ready"""
        get_instance = self.compute_client.get_instance(instance_id)
        while get_instance.data.lifecycle_state != "RUNNING":
            time.sleep(10)
            get_instance = self.compute_client.get_instance(instance_id)
        
        # Additional wait for SSH to be ready
        time.sleep(60)
        return get_instance.data

    def get_instance_ip(self, instance_id):
        """Get public and private IPs of the instance"""
        vnic_attachments = self.compute_client.list_vnic_attachments(
            compartment_id=self.config["compartment_id"],
            instance_id=instance_id
        ).data

        for vnic_attachment in vnic_attachments:
            vnic = self.network_client.get_vnic(vnic_attachment.vnic_id).data
            return vnic.public_ip, vnic.private_ip

    def configure_instance(self, public_ip):
        """Configure the instance (iptables rules and packages)"""
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        private_key = paramiko.RSAKey.from_private_key_file(self.config["ssh_private_key_path"])
        
        retries = 3
        while retries > 0:
            try:
                ssh.connect(public_ip, username="ubuntu", pkey=private_key)
                # Execute commands
                commands = [
                    "sudo iptables -F",
                    "sudo apt remove -yq iptables-persistent --purge",
                    "sudo apt update"
                    "sudo apt install bzip2"
                ]
                for cmd in commands:
                    stdin, stdout, stderr = ssh.exec_command(cmd)
                    stdout.channel.recv_exit_status()
                break
            except Exception as e:
                print(f"Retry connecting to {public_ip}. Attempts left: {retries}")
                retries -= 1
                time.sleep(10)
        
        ssh.close()

    def update_yaml(self, new_nodes):
        """Update the YAML file with new node information, appending to existing nodes"""
        try:
            with open(self.yaml_file, 'r') as f:
                yaml_config = yaml.safe_load(f) or {"nodes": []}
        except FileNotFoundError:
            yaml_config = {"nodes": []}

        yaml_config["nodes"].extend(new_nodes)

        with open(self.yaml_file, 'w') as f:
            yaml.dump(yaml_config, f, default_flow_style=False)

    def get_next_index(self, basename):
        """Get the next index for naming new nodes"""
        try:
            with open(self.yaml_file, 'r') as f:
                yaml_config = yaml.safe_load(f) or {"nodes": []}
            existing_hostnames = [node["hostname"] for node in yaml_config.get("nodes", [])]
            existing_indices = [
                int(hostname.split('-')[-1]) for hostname in existing_hostnames
                if hostname.startswith(basename) and hostname.split('-')[-1].isdigit()
            ]
            return max(existing_indices, default=0) + 1
        except FileNotFoundError:
            return 1

    def create_and_configure_instance(self, index, basename):
        """Create and configure a single instance"""
        try:
            display_name = f"{basename}-{index}"
            print(f"Creating instance {display_name}...")
            
            instance = self.create_instance(display_name)
            instance = self.wait_for_instance_ready(instance.id)
            public_ip, private_ip = self.get_instance_ip(instance.id)
            
            print(f"Configuring instance {display_name}...")
            self.configure_instance(public_ip)
            
            return {
                "hostname": display_name,
                "public_ip": public_ip,
                "private_ip": private_ip,
                "instance_id": instance.id,
                "creation_time": datetime.now().isoformat()
            }
        except Exception as e:
            print(f"Error creating instance {display_name}: {str(e)}")
            raise

    def deploy_nodes(self, count, basename):
        """Deploy multiple nodes concurrently"""
        nodes = []
        instance_ids = []
        futures = []

        print(f"Starting deployment of {count} nodes...")
        next_index = self.get_next_index(basename)
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            # Submit all creation tasks
            futures = [executor.submit(self.create_and_configure_instance, next_index + i, basename) 
                      for i in range(count)]
            
            # Process completed tasks
            for future in as_completed(futures):
                try:
                    node = future.result()
                    nodes.append(node)
                    instance_ids.append(node["instance_id"])
                    print(f"Successfully deployed {node['hostname']}")
                except Exception as e:
                    print(f"Failed to deploy node: {str(e)}")

        # Update configuration files
        print("Updating YAML configuration...")
        self.update_yaml(nodes)
        
        with open('instance_ids.txt', 'a') as f:  # Append to the file
            for id in instance_ids:
                f.write(f"{id}\n")
        
        print(f"Deployment completed successfully! Created {len(nodes)} nodes.")

    def terminate_instance(self, instance_id, hostname):
        """Terminate a single instance"""
        try:
            print(f"Terminating instance {hostname} ...")
            self.compute_client.terminate_instance(instance_id)
            
            retries = 3
            while retries > 0:
                try:
                    get_instance = self.compute_client.get_instance(instance_id)
                    state = get_instance.data.lifecycle_state
                    if state == "TERMINATED":
                        break
                    print(f"Waiting for instance {hostname} to terminate... Current state: {state}")
                    time.sleep(5)
                    retries -= 1
                except oci.exceptions.ServiceError as e:
                    if e.status == 404:  # Instance not found means it's terminated
                        break
                    if retries > 0:
                        print(f"Retrying... {retries} attempts left")
                        time.sleep(5)
                        retries -= 1
                    else:
                        raise
            
            return instance_id
        except Exception as e:
            print(f"Error terminating instance {hostname} : {str(e)}")
            raise

    def destroy_nodes(self, instance_ids=None):
        """Destroy multiple instances concurrently"""
        if not instance_ids:
            try:
                with open('instance_ids.txt', 'r') as f:
                    instance_ids = [line.strip() for line in f.readlines()]
            except FileNotFoundError:
                print("No instance IDs provided and instance_ids.txt not found.")
                return

        # Map instance IDs to hostnames
        instance_id_to_hostname = {}
        try:
            with open(self.yaml_file, 'r') as f:
                yaml_config = yaml.safe_load(f) or {"nodes": []}
                for node in yaml_config.get("nodes", []):
                    instance_id_to_hostname[node["instance_id"]] = node["hostname"]
        except FileNotFoundError:
            print(f"YAML file {self.yaml_file} not found.")
            return

        print(f"Starting termination of {len(instance_ids)} instances...")
        terminated_instances = []  # Keep track of successfully terminated instances
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = [executor.submit(self.terminate_instance, instance_id, instance_id_to_hostname.get(instance_id, "Unknown")) 
                      for instance_id in instance_ids]
            
            for future in as_completed(futures):
                try:
                    instance_id = future.result()
                    terminated_instances.append(instance_id)
                    print(f"Successfully terminated instance {instance_id_to_hostname.get(instance_id, 'Unknown')}")
                except Exception as e:
                    print(f"Failed to terminate instance: {str(e)}")
                    continue

        # Only update configuration files if we successfully terminated some instances
        if terminated_instances:
            try:
                # Update YAML file by removing only successfully terminated instances
                with open(self.yaml_file, 'r') as f:
                    yaml_config = yaml.safe_load(f) or {"nodes": []}
                
                # Filter out successfully terminated nodes
                original_length = len(yaml_config["nodes"])
                yaml_config["nodes"] = [
                    node for node in yaml_config["nodes"] 
                    if node.get("instance_id") not in terminated_instances
                ]
                
                # Only write back if we successfully filtered
                if len(yaml_config["nodes"]) != original_length:
                    try:
                        with open(self.yaml_file, 'w') as f:
                            yaml.dump(yaml_config, f, default_flow_style=False)
                        print("YAML configuration updated successfully.")
                    except Exception as e:
                        # Create backup only if writing fails
                        backup_file = f"{self.yaml_file}.backup"
                        with open(backup_file, 'w') as f:
                            yaml.dump(yaml_config, f, default_flow_style=False)
                        print(f"Error updating YAML file: {str(e)}")
                        print(f"YAML backup created at: {backup_file}")
                        return

                try:
                    # Update instance_ids.txt
                    if os.path.exists('instance_ids.txt'):
                        with open('instance_ids.txt', 'r') as f:
                            remaining_ids = [line.strip() for line in f.readlines() 
                                           if line.strip() not in terminated_instances]
                        
                        with open('instance_ids.txt', 'w') as f:
                            for id in remaining_ids:
                                f.write(f"{id}\n")
                except Exception as e:
                    # Create backup only if writing fails
                    with open('instance_ids.txt.backup', 'w') as f:
                        for id in remaining_ids:
                            f.write(f"{id}\n")
                    print(f"Error updating instance_ids.txt: {str(e)}")
                    print("Backup of instance_ids.txt is available at: instance_ids.txt.backup")

            except Exception as e:
                print(f"Error processing configuration files: {str(e)}")
                return

        print(f"Successfully terminated {len(terminated_instances)} out of {len(instance_ids)} instances!")
        if len(terminated_instances) < len(instance_ids):
            print("Some instances failed to terminate. Please check the logs above for details.")

    def stop_instance(self, instance_id, hostname):
        """Stop a single instance"""
        try:
            print(f"Stopping instance {hostname}...")
            self.compute_client.instance_action(instance_id, "STOP")
            
            while True:
                get_instance = self.compute_client.get_instance(instance_id)
                state = get_instance.data.lifecycle_state
                if state == "STOPPED":
                    break
                print(f"Waiting for instance {hostname} to stop... Current state: {state}")
                time.sleep(5)
            
            return instance_id
        except Exception as e:
            print(f"Error stopping instance {hostname}: {str(e)}")
            raise

    def start_instance(self, instance_id, hostname):
        """Start a single instance"""
        try:
            print(f"Starting instance {hostname}...")
            self.compute_client.instance_action(instance_id, "START")
            
            while True:
                get_instance = self.compute_client.get_instance(instance_id)
                state = get_instance.data.lifecycle_state
                if state == "RUNNING":
                    break
                print(f"Waiting for instance {hostname} to start... Current state: {state}")
                time.sleep(5)
            
            return instance_id
        except Exception as e:
            print(f"Error starting instance {hostname}: {str(e)}")
            raise

    def manage_instances(self, action, instance_ids):
        """Manage (stop/start) multiple instances concurrently"""
        if not instance_ids:
            print("No instance IDs provided.")
            return

        # Get hostname mapping
        instance_id_to_hostname = {}
        try:
            with open(self.yaml_file, 'r') as f:
                yaml_config = yaml.safe_load(f) or {"nodes": []}
                for node in yaml_config.get("nodes", []):
                    instance_id_to_hostname[node["instance_id"]] = node["hostname"]
        except FileNotFoundError:
            print(f"YAML file {self.yaml_file} not found.")
            return

        action_method = self.stop_instance if action == "stop" else self.start_instance
        print(f"Starting {action} operation for {len(instance_ids)} instances...")
        
        completed_count = 0
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = [executor.submit(action_method, instance_id, instance_id_to_hostname.get(instance_id, "Unknown")) 
                      for instance_id in instance_ids]
            
            for future in as_completed(futures):
                try:
                    instance_id = future.result()
                    hostname = instance_id_to_hostname.get(instance_id, "Unknown")
                    completed_count += 1
                    print(f"Successfully {action}ed instance {hostname}")
                except Exception as e:
                    print(f"Failed to {action} instance: {str(e)}")

        print(f"Successfully {action}ed {completed_count} out of {len(instance_ids)} instances!")

    def get_instance_id_by_hostname(self, hostname):
        """Retrieve instance ID by hostname from the YAML file"""
        try:
            with open(self.yaml_file, 'r') as f:
                yaml_config = yaml.safe_load(f)
                for node in yaml_config.get('nodes', []):
                    if node.get('hostname') == hostname:
                        return node.get('instance_id')
        except FileNotFoundError:
            print(f"YAML file {self.yaml_file} not found.")
        return None

    def manage_instances_by_hostname(self, action, hostnames):
        """Manage (stop/start/terminate) instances by hostname"""
        instance_ids = [self.get_instance_id_by_hostname(hostname) for hostname in hostnames]
        instance_ids = list(filter(None, instance_ids))  # Remove None values

        if not instance_ids:
            print("No valid instance IDs found for the provided hostnames.")
            return

        if action == "terminate":
            self.destroy_nodes(instance_ids)
        else:
            self.manage_instances(action, instance_ids)

def main():
    parser = argparse.ArgumentParser(description='OCI Node Manager')
    parser.add_argument('action', choices=['deploy', 'destroy', 'stop', 'start'], 
                       help='Action to perform')
    parser.add_argument('--count', type=int, help='Number of nodes to deploy', default=1)
    parser.add_argument('--concurrent', type=int, help='Maximum concurrent operations', 
                       default=5)
    parser.add_argument('--basename', type=str, help='Base name for the nodes', 
                        default='rafay-paas')
    parser.add_argument('--hostnames', nargs='+', help='List of hostnames to manage')
    
    args = parser.parse_args()
    
    manager = OCINodeManager()
    manager.max_workers = args.concurrent
    
    if args.action == 'deploy':
        manager.deploy_nodes(args.count, args.basename)
    elif args.action == 'destroy':
        if args.hostnames:
            # Selective termination by hostname
            manager.manage_instances_by_hostname('terminate', args.hostnames)
        else:
            # Terminate all instances
            manager.destroy_nodes()
    elif args.action in ['stop', 'start']:
        if not args.hostnames:
            print(f"Please provide hostnames to {args.action}")
            return
        manager.manage_instances_by_hostname(args.action, args.hostnames)

if __name__ == "__main__":
    main()
