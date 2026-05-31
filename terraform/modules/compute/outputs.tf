output "vm_name" {
  description = "VM name."
  value       = azurerm_linux_virtual_machine.this.name
}

output "ssh_private_key_pem" {
  description = "Generated private key for initial access."
  value       = tls_private_key.this.private_key_pem
  sensitive   = true
}