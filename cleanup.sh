#!/bin/bash

# Simple cleanup script for Terraform + Docker demo
# This script will destroy all infrastructure created by Terraform

set -e

echo "========================================"
echo "Terraform + Docker Demo - Cleanup Script"
echo "========================================"
echo ""

# Check if Terraform state exists
if [ ! -f "terraform.tfstate" ] && [ ! -f ".terraform/terraform.tfstate" ]; then
    echo "[INFO] No Terraform state found. Nothing to clean up."
    exit 0
fi

echo "This will destroy all infrastructure:"
echo "  - All containers (postgres, flask-app, nginx)"
echo "  - Docker network"
echo "  - Docker volume (database data will be lost!)"
echo ""

# Check if running in non-interactive mode
if [ "$1" == "-y" ] || [ "$1" == "--yes" ]; then
    AUTO_APPROVE="-auto-approve"
    echo "Running in auto-approve mode..."
else
    read -p "Are you sure you want to continue? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "Cleanup cancelled."
        exit 0
    fi
    AUTO_APPROVE="-auto-approve"
fi

echo ""
echo "Destroying infrastructure..."

terraform destroy $AUTO_APPROVE

echo ""
echo "Cleaning up Terraform files..."

# Remove Terraform lock file
if [ -f ".terraform.lock.hcl" ]; then
    rm -f .terraform.lock.hcl
    echo "[OK] Removed .terraform.lock.hcl"
fi

# Remove .terraform directory
if [ -d ".terraform" ]; then
    rm -rf .terraform
    echo "[OK] Removed .terraform directory"
fi

# Remove state backup files
if [ -f "terraform.tfstate.backup" ]; then
    rm -f terraform.tfstate.backup
    echo "[OK] Removed terraform.tfstate.backup"
fi

echo ""
echo "========================================"
echo "Cleanup Complete!"
echo "========================================"
echo ""
echo "All containers, networks, volumes, and Terraform files have been removed."
echo ""
echo "To deploy again, run: ./start.sh"
echo ""

