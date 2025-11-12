#!/bin/bash

# Verification script for Terraform + Docker demo
# This checks that all prerequisites are met

echo "Verifying setup for Terraform + Docker demo..."
echo ""

EXIT_CODE=0

# Check Docker
echo "1. Checking Docker..."
if command -v docker &> /dev/null; then
    echo "   [OK] Docker is installed: $(docker --version)"
    
    if docker ps &> /dev/null; then
        echo "   [OK] Docker daemon is running"
    else
        echo "   [ERROR] Docker daemon is not running. Please start Docker Desktop."
        EXIT_CODE=1
    fi
else
    echo "   [ERROR] Docker is not installed. Please install Docker Desktop for Mac."
    EXIT_CODE=1
fi

echo ""

# Check Terraform
echo "2. Checking Terraform..."
if command -v terraform &> /dev/null; then
    VERSION=$(terraform version -json 2>/dev/null | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
    echo "   [OK] Terraform is installed: $VERSION"
else
    echo "   [ERROR] Terraform is not installed."
    echo "   Install with: brew tap hashicorp/tap && brew install hashicorp/tap/terraform"
    EXIT_CODE=1
fi

echo ""

# Check port availability
echo "3. Checking port 8080 availability..."
if lsof -i :8080 &> /dev/null; then
    echo "   [WARNING] Port 8080 is already in use:"
    lsof -i :8080
    echo "   You can change the port in terraform.tfvars"
else
    echo "   [OK] Port 8080 is available"
fi

echo ""

# Summary
if [ $EXIT_CODE -eq 0 ]; then
    echo "[SUCCESS] All prerequisites met! You're ready to go."
    echo ""
    echo "Next steps:"
    echo "  1. terraform init"
    echo "  2. terraform apply"
    echo "  3. Open http://localhost:8080"
    echo ""
    echo "Or use the quick start:"
    echo "  make init"
    echo "  make apply"
    echo "  make test"
else
    echo "[ERROR] Please install missing prerequisites before continuing."
fi

exit $EXIT_CODE

