terraform {
  required_version = ">= 1.0"
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 5000
}

variable "nginx_port" {
  description = "Nginx external port"
  type        = number
  default     = 8080
}

# Custom network for our application
resource "docker_network" "app_network" {
  name = "${var.environment}-app-network"
  driver = "bridge"
  
  ipam_config {
    subnet = "172.20.0.0/16"
  }
}

# PostgreSQL database
resource "docker_image" "postgres" {
  name = "postgres:15-alpine"
}

resource "docker_volume" "postgres_data" {
  name = "${var.environment}-postgres-data"
}

resource "docker_container" "postgres" {
  name  = "${var.environment}-postgres"
  image = docker_image.postgres.image_id
  
  env = [
    "POSTGRES_DB=appdb",
    "POSTGRES_USER=appuser",
    "POSTGRES_PASSWORD=apppass123"
  ]
  
  networks_advanced {
    name = docker_network.app_network.name
    aliases = ["postgres"]
  }
  
  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }
  
  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }
}

# Build custom Flask application image
resource "docker_image" "flask_app" {
  name = "terraform-demo-app:latest"
  
  build {
    context    = "${path.module}/app"
    dockerfile = "Dockerfile"
    tag        = ["terraform-demo-app:latest"]
  }
  
  triggers = {
    dir_sha1 = sha1(join("", [
      filesha1("${path.module}/app/Dockerfile"),
      filesha1("${path.module}/app/app.py"),
      filesha1("${path.module}/app/requirements.txt")
    ]))
  }
}

# Flask application container
resource "docker_container" "flask_app" {
  name  = "${var.environment}-flask-app"
  image = docker_image.flask_app.image_id
  
  env = [
    "DATABASE_URL=postgresql://appuser:apppass123@postgres:5432/appdb",
    "FLASK_ENV=development"
  ]
  
  networks_advanced {
    name = docker_network.app_network.name
    aliases = ["flask-app"]
  }
  
  depends_on = [docker_container.postgres]
  
  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost:5000/health"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }
}

# Nginx reverse proxy
resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_container" "nginx" {
  name  = "${var.environment}-nginx"
  image = docker_image.nginx.image_id
  
  ports {
    internal = 80
    external = var.nginx_port
  }
  
  networks_advanced {
    name = docker_network.app_network.name
    aliases = ["nginx"]
  }
  
  volumes {
    host_path      = abspath("${path.module}/nginx/nginx.conf")
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }
  
  depends_on = [docker_container.flask_app]
}

