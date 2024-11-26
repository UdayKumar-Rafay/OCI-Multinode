#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to validate numeric input
validate_number() {
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: Please enter a valid number${NC}"
        return 1
    fi
    if [ "$1" -lt 1 ]; then
        echo -e "${RED}Error: Number must be at least 1${NC}"
        return 1
    fi
    return 0
}

# Function to deploy workers
deploy_workers() {
    # Get worker count from user
    while true; do
        echo -e "${YELLOW}How many worker nodes would you like to deploy? (minimum 1):${NC}"
        read worker_count
        if validate_number "$worker_count"; then
            break
        fi
    done

    echo
    echo -e "${GREEN}Running Terraform plan with ${worker_count} worker nodes...${NC}"
    echo

    # Run terraform plan with the specified worker count
    terraform plan -var="worker_instance_count=${worker_count}" -out=tfplan

    # Check if terraform plan was successful
    if [ $? -ne 0 ]; then
        echo
        echo -e "${RED}Terraform plan failed. Please check the errors above.${NC}"
        return 1
    fi

    # Ask for confirmation
    echo
    echo -e "${YELLOW}Do you want to apply this plan? (yes/no):${NC}"
    read confirmation

    # Convert confirmation to lowercase
    confirmation=$(echo "$confirmation" | tr '[:upper:]' '[:lower:]')

    if [ "$confirmation" = "yes" ] || [ "$confirmation" = "y" ]; then
        echo
        echo -e "${GREEN}Applying Terraform plan...${NC}"
        terraform apply tfplan
        
        # Check if terraform apply was successful
        if [ $? -eq 0 ]; then
            echo
            echo -e "${GREEN}Deployment completed successfully!${NC}"
            
            # Clean up the plan file
            rm -f tfplan
        else
            echo
            echo -e "${RED}Deployment failed. Please check the errors above.${NC}"
            # Clean up the plan file
            rm -f tfplan
            return 1
        fi
    else
        echo
        echo -e "${YELLOW}Deployment cancelled.${NC}"
        # Clean up the plan file
        rm -f tfplan
    fi
}

# Function to destroy infrastructure
# Function to destroy infrastructure
destroy_workers() {
    echo -e "${RED}WARNING: This will destroy all worker nodes and associated resources!${NC}"
    echo
    
    # Get the current node count from YAML
    current_count=$(python3 -c '
import ruamel.yaml
yaml = ruamel.yaml.YAML()
with open("/Users/uday/mks-scale/uday-nodes.yaml", "r") as f:
    config = yaml.load(f)
print(len(config.get("nodes", [])))
')

    echo -e "${YELLOW}Current worker count: ${current_count}${NC}"
    echo -e "${YELLOW}Are you sure you want to destroy all resources? (yes/no):${NC}"
    read confirmation

    # Convert confirmation to lowercase
    confirmation=$(echo "$confirmation" | tr '[:upper:]' '[:lower:]')

    if [ "$confirmation" = "yes" ] || [ "$confirmation" = "y" ]; then
        echo
        echo -e "${GREEN}Running Terraform destroy...${NC}"
        
        # Run terraform destroy with the current worker count
        terraform destroy -auto-approve -var="worker_instance_count=${current_count}"

        if [ $? -eq 0 ]; then
            echo
            echo -e "${GREEN}Infrastructure destroyed successfully!${NC}"
            
            # Clear the nodes from YAML file
            echo -e "${GREEN}Clearing node configurations...${NC}"
            # Clear the collected configs JSON
            echo "[]" > /tmp/collected_node_configs.json
            
            # Clear the nodes in YAML using Python
            python3 -c '
import ruamel.yaml
yaml = ruamel.yaml.YAML()
yaml.preserve_quotes = True
yaml.indent(mapping=2, sequence=4, offset=2)

# Initialize empty nodes structure
config = {"nodes": []}

# Write the cleared configuration
with open("/Users/uday/mks-scale/uday-nodes.yaml", "w") as f:
    yaml.dump(config, f)
'
            echo -e "${GREEN}Node configurations cleared successfully!${NC}"
        else
            echo
            echo -e "${RED}Destroy operation failed. Please check the errors above.${NC}"
            return 1
        fi
    else
        echo
        echo -e "${YELLOW}Destroy operation cancelled.${NC}"
    fi
}

# Main menu
show_menu() {
    clear
    echo -e "${GREEN}=== Worker Node Management Script ===${NC}"
    echo
    echo "1) Deploy worker nodes"
    echo "2) Destroy infrastructure"
    echo "3) Exit"
    echo
    echo -e "${YELLOW}Please enter your choice (1-3):${NC}"
}

# Main loop
while true; do
    show_menu
    read choice

    case $choice in
        1)
            deploy_workers
            echo
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read
            ;;
        2)
            destroy_workers
            echo
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read
            ;;
        3)
            echo
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            sleep 2
            ;;
    esac
done