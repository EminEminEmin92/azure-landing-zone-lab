variable "resource_group_name" {
  description = "Name der bestehenden Resource Group, in der das Netzwerk angelegt wird."
  type        = string
}

variable "location" {
  description = "Azure-Region fuer alle Netzwerk-Ressourcen."
  type        = string
}

variable "tags" {
  description = "Tags, die auf alle Ressourcen des Moduls gesetzt werden."
  type        = map(string)
}

variable "vnet_name" {
  description = "Name des Virtual Network, z.B. vnet-lab-dev."
  type        = string
}

variable "vnet_address_space" {
  description = "Adressbereich des Virtual Network in CIDR-Notation, z.B. 10.10.0.0/16."
  type        = string

  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0))
    error_message = "vnet_address_space muss ein gueltiger CIDR-Bereich sein, z.B. 10.10.0.0/16."
  }
}

variable "subnet_name" {
  description = "Name des Subnetzes, z.B. snet-workload."
  type        = string
}

variable "subnet_address_prefix" {
  description = "Adressbereich des Subnetzes in CIDR-Notation, muss innerhalb des VNet liegen, z.B. 10.10.1.0/24."
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_address_prefix, 0))
    error_message = "subnet_address_prefix muss ein gueltiger CIDR-Bereich sein, z.B. 10.10.1.0/24."
  }
}

variable "nsg_name" {
  description = "Name der Network Security Group fuer das Subnetz, z.B. nsg-workload-dev."
  type        = string
}
