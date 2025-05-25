# outputs.tf

# Affiche les adresses IP privées des VMs applicatives
output "vm_ips" {
  description = "Adresses IP privées des VMs applicatives"
  value       = azurerm_network_interface.nic[*].private_ip_address
}

# Affiche l'adresse IP publique du Load Balancer
output "lb_public_ip" {
  description = "Adresse IP publique du Load Balancer"
  value       = azurerm_public_ip.lb_pip.ip_address
}

# Affiche l'adresse IP publique de MongoDB
output "mongodb_public_ip" {
  description = "Adresse IP publique de MongoDB"
  value       = azurerm_public_ip.mongodb_pip.ip_address
}
