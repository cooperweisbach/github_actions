terraform {
    backend "remote" {
        hostname = "app.terraform.io"
        organization = "personal-github-5885"

        workspaces {
            name = "github_actions"
        }
    }
}

terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
      }
    }
}

provider "aws" {
    region = "us-west-2"
}