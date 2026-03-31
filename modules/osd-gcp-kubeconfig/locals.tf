locals {

  cluster_details = {
    cluster_name   = jsondecode(base64decode(data.google_secret_manager_secret_version.cluster_details.secret_data)).cluster_name
    console_url    = jsondecode(base64decode(data.google_secret_manager_secret_version.cluster_details.secret_data)).console_url
    api_server_url = jsondecode(base64decode(data.google_secret_manager_secret_version.cluster_details.secret_data)).api_server_url
    admin_username = jsondecode(base64decode(data.google_secret_manager_secret_version.cluster_details.secret_data)).admin_username
    admin_password = jsondecode(base64decode(data.google_secret_manager_secret_version.cluster_details.secret_data)).admin_password
  }

  acmhub_details = {
    cluster_name   = length(data.google_secret_manager_secret_version.acmhub_details) > 0 ? jsondecode(base64decode(data.google_secret_manager_secret_version.acmhub_details[0].secret_data)).cluster_name : ""
    console_url    = length(data.google_secret_manager_secret_version.acmhub_details) > 0 ? jsondecode(base64decode(data.google_secret_manager_secret_version.acmhub_details[0].secret_data)).console_url : ""
    api_server_url = length(data.google_secret_manager_secret_version.acmhub_details) > 0 ? jsondecode(base64decode(data.google_secret_manager_secret_version.acmhub_details[0].secret_data)).api_server_url : ""
    admin_username = length(data.google_secret_manager_secret_version.acmhub_details) > 0 ? sensitive(jsondecode(base64decode(data.google_secret_manager_secret_version.acmhub_details[0].secret_data)).admin_username) : ""
    admin_password = length(data.google_secret_manager_secret_version.acmhub_details) > 0 ? sensitive(jsondecode(base64decode(data.google_secret_manager_secret_version.acmhub_details[0].secret_data)).admin_password) : ""
  }

}