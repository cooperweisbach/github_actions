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
        version = "~> 3.0"
      }
    }
    required_version = ">= 1.1.0"
}

provider "aws" {
    region = "us-west-2"
}
