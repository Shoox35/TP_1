# variables.tf

# Nom du Resource Group Azure
variable "resource_group_name" {
  description = "Nom du Resource Group Azure"
  type        = string
}

# Région Azure (par exemple, westeurope pour la France)
variable "location" {
  description = "Région Azure"
  type        = string
  default     = "westeurope"
}

# Nom du Virtual Network
variable "vnet_name" {
  description = "Nom du Virtual Network"
  type        = string
  default     = "vnet-app"
}

# Plage d'adresses du VNet (par exemple, 10.0.0.0/16)
variable "vnet_address_space" {
  description = "Plage d'adresses du VNet"
  type        = string
  default     = "10.0.0.0/16"
}

# Nom du subnet
variable "subnet_name" {
  description = "Nom du subnet"
  type        = string
  default     = "subnet-app"
}

# Plage d'adresses du subnet (par exemple, 10.0.1.0/24)
variable "subnet_address_prefix" {
  description = "Plage d'adresses du subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Taille des VMs (par exemple, B1ms pour une petite VM)
variable "vm_size" {
  description = "Taille des VMs"
  type        = string
  default     = "Standard_B1ms"
}

# Nom d'utilisateur admin pour SSH
variable "admin_username" {
  description = "Nom d'utilisateur admin pour SSH"
  type        = string
  default     = "azureuser"
}

# Chemin vers la clé publique SSH (pour usage local seulement)
variable "ssh_public_key_path" {
  description = "Chemin vers la clé publique SSH (pour usage local seulement) - DEPRECATED for CI/CD, use ssh_public_key_content instead."
  type        = string
  default     = null
}

# Contenu de la clé publique SSH (à fournir via une variable CI/CD)
variable "ssh_public_key_content" {
  description = "Contenu de la clé publique SSH (à fournir via une variable CI/CD)"
  type        = string
  sensitive   = true
}

# Port exposé par l'application (par exemple, 8080)
variable "app_port" {
  description = "Port exposé par l'application"
  type        = string
  default     = "8080"
}
