# ----- backends.tf ----- #

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "pmvs"

    workspaces {
      name = "pmvs-ecs"
    }
  }
}