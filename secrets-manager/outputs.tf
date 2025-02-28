# Output the secret name
output "secret_name" {
  value = google_secret_manager_secret.bu_keyvault.name
}