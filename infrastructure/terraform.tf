terraform {
    backend "remote" {
        hostname = "app.terraform.io"
        organization = "personal-github-5885"

        workspaces {
            name = "github_actions"
        }
    }
}