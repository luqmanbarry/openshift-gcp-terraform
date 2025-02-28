
## Load the tfvars file
data "local_file" "tfvars_file_content" {
  filename  = local.tfvars_file
}

# resource "null_resource" "commit_tfvars_file" {

#   provisioner "local-exec" {
#     interpreter = [ "/bin/bash", "-c" ]
#     command = "git add \"$TFVARS_FILE\""

#     environment = {
#       TFVARS_FILE     = data.local_file.tfvars_file_content.filename
#     }
#   }

#   provisioner "local-exec" {
#     interpreter = [ "/bin/bash", "-c" ]
#     command = "git commit -am \"$COMMIT_MESSAGE\""
    
#     environment = {
#       COMMIT_MESSAGE  = local.message
#     }
#   }

#   provisioner "local-exec" {
#     interpreter = [ "/bin/bash", "-c" ]
#     command = "git push origin \"$BRANCH\""
    
#     environment = {
#       BRANCH          = var.git_branch
#     }
#   }
# }


resource "git_add" "tfvars_file" {
  directory = local.local_repository_dir
  add_paths = [ local.tfvars_file ]
}

resource "git_commit" "commit_on_tfvars_change" {
  directory = local.local_repository_dir
  message   = local.message

  author = {
    name  = var.git_username
    email = var.git_commit_email
  }

  committer = {
    name  = var.git_username
    email = var.git_commit_email
  }

  lifecycle {
    replace_triggered_by = [ git_add.tfvars_file.id ]
  }
}

resource "git_push" "push_tfvars_file" {
  directory = local.local_repository_dir
  refspecs  = [ format("refs/heads/%s:refs/heads/%s", var.git_branch, var.git_branch) ]
  force     = true

  auth = {
    basic = {
      username = var.git_username
      password = var.git_token
    }
  }

  lifecycle {
    replace_triggered_by = [ git_commit.commit_on_tfvars_change.id ]
  }
}


# ## GitHub: Commit tfvar file to remote repository
# resource "github_repository_file" "commit_tfvars_file" {
#   repository                = var.git_repository_name
#   branch                    = var.git_branch
#   file                      = data.local_file.tfvars_file_content.filename
#   content                   = data.local_file.tfvars_file_content.content
#   commit_message            = local.message
#   commit_author             = var.git_username
#   commit_email              = var.git_commit_email
#   overwrite_on_create       = true
# }