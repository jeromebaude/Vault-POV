# Hashicorp Vault Proof of Value

These Terraform scripts deploy 3 VM (vault1, vault2, vault3) and a Jumphost. SSH access is only possible to the Jumphost where Ansible is installed.

The Jumphost has SSH access to the 3 VM, ansible installed, playbook and hosts file configured. Ready for Vault to be deployed.

## 1. To be done

Update the site.yml with your Vault preferred version
Update the certificate and private key ./files/vault.crt ./files/vault.key
Update the Hosted Zone ID for your domain and Sub domains
Update the hosts file accordingly
Provide the necessary variable in terraform.tfvars or in TFE variable section (prefix, awsami, vm_size, id_rsapub, jba_key_pub, hostedzoneid)
