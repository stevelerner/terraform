output "application_url" {
  description = "URL to access the application"
  value       = "http://localhost:${var.nginx_port}"
}

output "database_container" {
  description = "Database container name"
  value       = docker_container.postgres.name
}

output "app_container" {
  description = "Application container name"
  value       = docker_container.flask_app.name
}

output "nginx_container" {
  description = "Nginx container name"
  value       = docker_container.nginx.name
}

output "network_name" {
  description = "Docker network name"
  value       = docker_network.app_network.name
}

output "containers_info" {
  description = "Summary of all containers"
  value = {
    postgres = {
      name = docker_container.postgres.name
      ip   = docker_container.postgres.network_data[0].ip_address
    }
    flask_app = {
      name = docker_container.flask_app.name
      ip   = docker_container.flask_app.network_data[0].ip_address
    }
    nginx = {
      name = docker_container.nginx.name
      ip   = docker_container.nginx.network_data[0].ip_address
    }
  }
}

