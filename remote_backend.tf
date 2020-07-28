terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "monaco-vault-pov"
    workspaces {
      name = "Vault-POV-test"
    }
  }
}
