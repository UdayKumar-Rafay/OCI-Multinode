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
            "image_id": "ocid1.image.oc1.phx.aaaaaaaabs7vrxje4vil2yaijt3rwuk6ylnxnlza5p3ovj7t7kwrqih3bfta",
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
                ocpus=1,
                memory_in_gbs=4
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
        """Configure the instance (iptables rules)"""
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        private_key = paramiko.RSAKey.from_private_key_file(self.config["ssh_private_key_path"])
        
        retries = 3
        while retries > 0:
            try:
                ssh.connect(public_ip, username="ubuntu", pkey=private_key)
                stdin, stdout, stderr = ssh.exec_command("sudo iptables -F; sudo iptables -t nat -F;")
                stdout.channel.recv_exit_status()
                break
            except Exception as e:
                print(f"Retry connecting to {public_ip}. Attempts left: {retries}")
                retries -= 1
                time.sleep(10)
        
        ssh.close()

    def update_yaml(self, nodes):
        """Update the YAML file with node information"""
        yaml_config = {"nodes": []}
        
        for node in nodes:
            yaml_config["nodes"].append({
                "arch": "amd64",
                "hostname": node["hostname"],
                "operatingSystem": "Ubuntu20.04",
                "privateip": node["private_ip"],
                "ssh": {
                    "ipAddress": node["public_ip"],
                    "port": "22",
                    "username": "ubuntu"
                },
                "instance_id": node["instance_id"]
            })

        with open(self.yaml_file, 'w') as f:
            yaml.dump(yaml_config, f, default_flow_style=False)

    def create_and_configure_instance(self, index):
        """Create and configure a single instance"""
        try:
            display_name = f"uday-test-{index+1}"
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

    def deploy_nodes(self, count):
        """Deploy multiple nodes concurrently"""
        nodes = []
        instance_ids = []
        futures = []

        print(f"Starting deployment of {count} nodes...")
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            # Submit all creation tasks
            futures = [executor.submit(self.create_and_configure_instance, i) 
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
        
        with open('instance_ids.txt', 'w') as f:
            for id in instance_ids:
                f.write(f"{id}\n")
        
        print(f"Deployment completed successfully! Created {len(nodes)} nodes.")

    def terminate_instance(self, instance_id):
        """Terminate a single instance"""
        try:
            print(f"Terminating instance {instance_id}...")
            self.compute_client.terminate_instance(instance_id)
            
            while True:
                try:
                    get_instance = self.compute_client.get_instance(instance_id)
                    state = get_instance.data.lifecycle_state
                    if state == "TERMINATED":
                        break
                    print(f"Waiting for instance {instance_id} to terminate... Current state: {state}")
                    time.sleep(5)
                except oci.exceptions.ServiceError as e:
                    if e.status == 404:  # Instance not found means it's terminated
                        break
                    raise
            
            return instance_id
        except Exception as e:
            print(f"Error terminating instance {instance_id}: {str(e)}")
            raise

    def destroy_nodes(self):
        """Destroy all nodes concurrently"""
        try:
            # Get instance IDs from both YAML and backup file
            instance_ids = set()
            
            # Try reading from YAML
            try:
                with open(self.yaml_file, 'r') as f:
                    yaml_config = yaml.safe_load(f)
                    instance_ids.update(node.get('instance_id') 
                                     for node in yaml_config.get('nodes', []))
            except FileNotFoundError:
                pass

            # Try reading from backup file
            try:
                with open('instance_ids.txt', 'r') as f:
                    instance_ids.update(line.strip() for line in f.readlines())
            except FileNotFoundError:
                pass

            instance_ids = list(filter(None, instance_ids))  # Remove None values

            if not instance_ids:
                print("No instance IDs found to terminate.")
                return

            print(f"Starting termination of {len(instance_ids)} instances...")
            terminated_count = 0
            
            with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
                # Submit all termination tasks
                futures = [executor.submit(self.terminate_instance, instance_id) 
                          for instance_id in instance_ids]
                
                # Process completed tasks
                for future in as_completed(futures):
                    try:
                        instance_id = future.result()
                        terminated_count += 1
                        print(f"Successfully terminated instance {instance_id}")
                    except Exception as e:
                        print(f"Failed to terminate instance: {str(e)}")

            # Clear configuration files
            with open(self.yaml_file, 'w') as f:
                yaml.dump({"nodes": []}, f)

            try:
                os.remove('instance_ids.txt')
            except FileNotFoundError:
                pass

            print(f"Successfully terminated {terminated_count} out of {len(instance_ids)} instances!")
            print("YAML configuration cleared.")

        except Exception as e:
            print(f"Error during destroy operation: {str(e)}")
            raise

def main():
    parser = argparse.ArgumentParser(description='OCI Node Manager')
    parser.add_argument('action', choices=['deploy', 'destroy'], help='Action to perform')
    parser.add_argument('--count', type=int, help='Number of nodes to deploy', default=1)
    parser.add_argument('--concurrent', type=int, help='Maximum concurrent operations', default=5)
    
    args = parser.parse_args()
    
    manager = OCINodeManager()
    manager.max_workers = args.concurrent
    
    if args.action == 'deploy':
        manager.deploy_nodes(args.count)
    else:
        manager.destroy_nodes()

if __name__ == "__main__":
    main()