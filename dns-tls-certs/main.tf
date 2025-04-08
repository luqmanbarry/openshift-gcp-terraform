# Add CAA record
resource "google_dns_record_set" "add_caa_record" {
  name                = var.custom_dns_domain_name
  type                = "CAA"
  managed_zone        = var.custom_dns_domain_name
  project             = var.base_dns_zone_project
  ttl                 = var.dns_ttl
  # These are basic examples; update the list to match your requirements.
  rrdatas             = [
    format("0 issuewild \"%s\"", var.custom_dns_domain_name),
    "0 issuewild \"letsencrypt.org\"",
    "0 issue \"letsencrypt.org\"",
    "0 issue \"digicert.com\""
  ]
}