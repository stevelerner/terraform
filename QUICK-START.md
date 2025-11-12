# Quick Start Guide

Get up and running in 1 minute!

## Super Simple Start

```bash
cd /Volumes/external/code/terraform
./start.sh
```

That's it! The script will:
- Check prerequisites
- Initialize Terraform
- Deploy everything
- Show you the URL

## Super Simple Cleanup

When you're done:

```bash
./cleanup.sh
```

## Manual 3-Step Setup

If you prefer to run commands yourself:

### Prerequisites Check

```bash
# 1. Is Docker running?
docker ps

# 2. Is Terraform installed?
terraform --version
```

If either command fails, see the main README.md for installation instructions.

### Step 1: Initialize

```bash
cd /Volumes/external/code/terraform
terraform init
```

Expected output: "Terraform has been successfully initialized!"

### Step 2: Deploy

```bash
terraform apply
```

When prompted, type: `yes`

Wait 30-60 seconds for containers to build and start.

### Step 3: Test

Open in browser:
```
http://localhost:8080
```

Or use curl:
```bash
curl http://localhost:8080
```

## Success!

You should see a JSON response with endpoints and information.

## Try It Out

```bash
# Record a visit
curl -X POST http://localhost:8080/visit \
  -H "Content-Type: application/json" \
  -d '{"message": "My first Terraform deployment!"}'

# View all visits
curl http://localhost:8080/visits

# Get stats
curl http://localhost:8080/stats
```

## Using the Makefile (Optional)

```bash
# Quick test of all endpoints
make test

# View container status
make status

# View logs
make logs

# See all available commands
make help
```

## Clean Up

### Simple Method

```bash
./cleanup.sh
```

### Manual Method

```bash
terraform destroy
```

Type `yes` when prompted.

## What Just Happened?

Terraform:
1. Created a Docker network
2. Pulled PostgreSQL and Nginx images
3. Built a custom Flask application image
4. Started 3 containers with proper networking
5. Configured volumes for persistent data
6. Set up health checks

All with one command: `terraform apply`

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Modify `terraform.tfvars` to change ports
- Edit `app/app.py` to add features
- Run `terraform apply` again to see incremental updates
- Try `make status` to inspect your infrastructure

## Troubleshooting

**Port 8080 already in use?**
```bash
# Edit terraform.tfvars and change nginx_port to 9090
terraform apply
```

**Containers not starting?**
```bash
# Check logs
docker logs dev-flask-app
docker logs dev-postgres
```

**Need to start over?**
```bash
terraform destroy
terraform apply
```

Happy Terraforming!

