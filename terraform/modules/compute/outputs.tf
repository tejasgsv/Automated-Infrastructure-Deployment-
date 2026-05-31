output "public_ip_address" {
  description = "Public IP address assigned to the VM."
  value       = azurerm_public_ip.this.ip_address
}

output "vm_name" {
  description = "VM name."
  value       = azurerm_linux_virtual_machine.this.name
}

output "ssh_private_key_pem" {
  description = "Generated private key for initial access."
  value       = tls_private_key.this.private_key_pem
  sensitive   = true
}