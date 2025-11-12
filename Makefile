.PHONY: help init plan apply destroy clean logs status test

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform
	terraform init

plan: ## Show Terraform execution plan
	terraform plan

apply: ## Apply Terraform configuration
	terraform apply

destroy: ## Destroy all Terraform-managed infrastructure
	terraform destroy

clean: ## Clean up Terraform files and Docker resources
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	docker system prune -f

logs: ## Show logs from all containers
	@echo "=== Nginx Logs ==="
	@docker logs dev-nginx 2>&1 | tail -20
	@echo "\n=== Flask App Logs ==="
	@docker logs dev-flask-app 2>&1 | tail -20
	@echo "\n=== PostgreSQL Logs ==="
	@docker logs dev-postgres 2>&1 | tail -20

status: ## Show status of all containers
	@echo "=== Terraform Outputs ==="
	@terraform output 2>/dev/null || echo "Run 'make apply' first"
	@echo "\n=== Docker Containers ==="
	@docker ps --filter "name=dev-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo "\n=== Docker Network ==="
	@docker network inspect dev-app-network --format '{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}' 2>/dev/null || echo "Network not created yet"

test: ## Test the application endpoints
	@echo "Testing application endpoints..."
	@echo "\n1. Health check:"
	@curl -s http://localhost:8080/health | python3 -m json.tool
	@echo "\n\n2. Home page:"
	@curl -s http://localhost:8080/ | python3 -m json.tool
	@echo "\n\n3. Recording a visit:"
	@curl -s -X POST http://localhost:8080/visit \
		-H "Content-Type: application/json" \
		-d '{"message": "Test from Makefile"}' | python3 -m json.tool
	@echo "\n\n4. Getting visits:"
	@curl -s http://localhost:8080/visits | python3 -m json.tool
	@echo "\n\n5. Statistics:"
	@curl -s http://localhost:8080/stats | python3 -m json.tool

shell-app: ## Open shell in Flask app container
	docker exec -it dev-flask-app sh

shell-db: ## Open PostgreSQL shell
	docker exec -it dev-postgres psql -U appuser -d appdb

shell-nginx: ## Open shell in Nginx container
	docker exec -it dev-nginx sh

validate: ## Validate Terraform configuration
	terraform validate
	terraform fmt -check

format: ## Format Terraform files
	terraform fmt -recursive

graph: ## Generate dependency graph
	terraform graph | dot -Tpng > infrastructure-graph.png
	@echo "Graph saved to infrastructure-graph.png"

