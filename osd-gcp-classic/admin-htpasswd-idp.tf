# Generate HTPasswd username/password
resource "null_resource" "run_every_time" {
  triggers = {
    timestamp = timestamp()
  }
}

resource "random_uuid" "admin_username" {
  depends_on = [ null_resource.get_cluster_details ]

  lifecycle {
    replace_triggered_by = [ null_resource.run_every_time ]
  }
}

resource "local_file" "save_username_to_file" {
  content  = random_uuid.admin_username.result
  filename = local.admin_username_content_path
}

resource "random_password" "admin_password" {
  depends_on = [ null_resource.get_cluster_details ]

  length           = 50
  special          = true
  min_special      = 3
  override_special = "!@#$%^*()_-+={}|;:',.?~"

  lifecycle {
    replace_triggered_by = [ null_resource.run_every_time ]
  }
}

resource "local_file" "save_password_to_file" {
  content  = random_password.admin_password.result
  filename = local.admin_password_content_path
}

resource "local_file" "save_htpasswod_idp_configs_to_file" {
  depends_on = [ local_file.save_username_to_file, local_file.save_password_to_file ]

  content  = local.htpasswd_idp_payload_json
  filename = local.htpasswd_idp_payload_file
}

resource "local_file" "save_idp_cluster_admin_tenant_to_file" {
  depends_on = [ local_file.save_htpasswod_idp_configs_to_file ]

  content  = local.idp_cluster_admin_tenant
  filename = local.idp_cluster_admin_tenant_file
}

resource "null_resource" "get_default_idp_id" {
  depends_on = [ local_file.save_idp_cluster_admin_tenant_to_file ]

  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = <<EOT
      ocm get /api/clusters_mgmt/v1/clusters/$CLUSTER_ID/identity_providers --parameter search="name like '$DEFAULT_IDP_NAME%'" | jq -r '.items[].id' | xargs > $DEFAULT_IDP_ID_FILE
    EOT
    environment = {
      DEFAULT_IDP_NAME          = local.default_idp_name
      CLUSTER_ID                = trimspace(file(local.cluster_id_file))
      DEFAULT_IDP_ID_FILE       = local.default_idp_id_file
    }
  }

  lifecycle {
    replace_triggered_by = [ random_uuid.admin_username, random_password.admin_password ]
  }
}

resource "null_resource" "get_default_admin_user_id" {
  depends_on = [ null_resource.get_default_idp_id ]

  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = <<EOT
      #ocm get /api/clusters_mgmt/v1/clusters/$CLUSTER_ID/groups/$DEFAULT_GROUP/users | jq -r '.items[].id' | xargs > $DEFAULT_ADMIN_USER_ID_FILE
      ocm get /api/clusters_mgmt/v1/clusters/$CLUSTER_ID/identity_providers/$IDP_ID/htpasswd_users | jq -r '.items[].username' | xargs > $DEFAULT_ADMIN_USER_ID_FILE
    EOT
    environment = {
      DEFAULT_GROUP               = local.default_user_group
      CLUSTER_ID                  = trimspace(file(local.cluster_id_file))
      DEFAULT_ADMIN_USER_ID_FILE  = local.default_admin_user_id_file
      IDP_ID                      = trimspace(file(local.default_idp_id_file))

    }
  }

  lifecycle {
    replace_triggered_by = [ random_uuid.admin_username, random_password.admin_password ]
  }
}

resource "null_resource" "cleanup_default_ipd" {
  depends_on = [ 
    null_resource.get_default_admin_user_id
  ]

  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = <<EOT
      set -x && \
      echo "Delete the default Identity Provider" && \
      ocm delete /api/clusters_mgmt/v1/clusters/$CLUSTER_ID/identity_providers/$IDP_ID || true && \
      echo "Delete the default user" && \
      for user_id in $DEFAULT_USER_ID; do ocm delete /api/clusters_mgmt/v1/clusters/$CLUSTER_ID/groups/$DEFAULT_GROUP/users/$user_id || true; sleep 5; done || true && \
      sleep 10
    EOT

    environment = {
      DEFAULT_IDP_NAME          = local.default_idp_name
      DEFAULT_USER_ID           = file(local.default_admin_user_id_file)
      DEFAULT_GROUP             = local.default_user_group
      CLUSTER_ID                = trimspace(file(local.cluster_id_file))
      IDP_ID                    = trimspace(file(local.default_idp_id_file))
      HTPASSWD_IDP_FILE         = local.htpasswd_idp_payload_file
    }
  }

  lifecycle {
    replace_triggered_by = [ random_uuid.admin_username, random_password.admin_password ]
  }
}

resource "null_resource" "create_htpasswd_idp" {
  depends_on = [ null_resource.cleanup_default_ipd ]

  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = <<EOT
      echo "Create the HTPasswd Identity Provider" && \
      ocm post /api/clusters_mgmt/v1/clusters/$CLUSTER_ID/identity_providers --body=$HTPASSWD_IDP_FILE && \
      sleep 10
    EOT
    environment = {
      CLUSTER_ID        = trimspace(file(local.cluster_id_file))
      HTPASSWD_IDP_FILE = local.htpasswd_idp_payload_file
    }
  }

  lifecycle {
    replace_triggered_by = [ random_uuid.admin_username, random_password.admin_password ]
  }

}

resource "null_resource" "grant_cluster_admin_role" {
  depends_on = [ null_resource.create_htpasswd_idp ]

  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = <<EOT
      echo "Grant default user cluster-admins role" && \
      ocm post /api/clusters_mgmt/v1/clusters/$CLUSTER_ID/groups/cluster-admins/users --body=$IDP_TENANT_PAYLOAD_FILE && \
      sleep 10
    EOT
    environment = {
      CLUSTER_ID              = trimspace(file(local.cluster_id_file))
      IDP_TENANT_PAYLOAD_FILE = local.idp_cluster_admin_tenant_file
    }
  }

  lifecycle {
    replace_triggered_by = [ random_uuid.admin_username, random_password.admin_password ]
  }
}











