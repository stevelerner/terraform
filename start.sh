#!/bin/bash

# Simple start script for Terraform + Docker demo
# This script will initialize and deploy the entire stack

echo "========================================"
echo "Terraform + Docker Demo - Start Script"
echo "========================================"
echo ""

# Check if Docker is running
echo "Checking prerequisites..."
if ! docker ps &> /dev/null; then
    echo "[ERROR] Docker is not running. Please start Docker Desktop for Mac."
    echo ""
    echo "To start Docker:"
    echo "  1. Open Docker Desktop application"
    echo "  2. Wait for it to finish starting"
    echo "  3. Run this script again"
    echo ""
    return 1 2>/dev/null || exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo "[ERROR] Terraform is not installed."
    echo "Install with: brew tap hashicorp/tap && brew install hashicorp/tap/terraform"
    exit 1
fi

echo "[OK] Docker is running"
echo "[OK] Terraform is installed"
echo ""

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
    echo ""
fi

# Apply the configuration
echo "Deploying infrastructure..."
echo "This will create:"
echo "  - PostgreSQL database"
echo "  - Flask application"
echo "  - Nginx reverse proxy"
echo "  - Custom network and volume"
echo ""

terraform apply -auto-approve

echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo ""

# Show the outputs
terraform output

echo ""
echo "Your application is now running!"
echo ""
echo "Access it at: http://localhost:8080"
echo ""
echo "Try these commands:"
echo "  curl http://localhost:8080"
echo "  curl http://localhost:8080/health"
echo "  curl http://localhost:8080/stats"
echo ""
echo "To stop and remove everything, run: ./cleanup.sh"
echo ""

