##############################################################################
# Variables File
#
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
}

variable "region" {
  description = "The amazon region to use."
  default     = "eu-west-3"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "t3.medium"
}

variable "awsami" {
  description = "AWS AMI Ubuntu 18.04 LTS"
  default = "ami-0cf777d3cf97a1518"
}

variable "create" {
  description = "Create Module, defaults to true."
  default     = true
}

variable "id_rsapub" {
  description = "Public Key"
  default     = ""
}

variable "jba_key_pub" {
  description = "Public Key for Jerome Baude"
  default     = ""
}

variable "gdo_key_pub" {
  description = "Public Key for Gauthier Donikian"
  default     = ""
}

variable "jpa_key_pub" {
  description = "Public Key for Jerome Papazian"
  default     = ""
}

variable "jye_key_pub" {
  description = "Public Key for Jacques Ye"
  default     = ""
}

variable "aso_key_pub" {
  description = "Public Key for Amine Souabni"
  default     = ""
}
variable "cla_key_pub" {
  description = "Public Key for Christophe Larue"
  default     = ""
}

variable "base_fqdn" {
  description = "Fully Qualified Domain Name for route 53"
}

variable "hostedzoneid" {
  description = "Hosted Zone ID"
  default     = ""
}

variable "nvault_instance" {
  type        = number
  description = "Number of Vault instance wanted"
}
