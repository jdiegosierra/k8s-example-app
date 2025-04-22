output "prometheus_namespace" {
  description = "The namespace where Prometheus and Grafana are deployed"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_admin_password" {
  description = "Admin password for Grafana"
  value       = var.grafana_admin_password
  sensitive   = true
} 