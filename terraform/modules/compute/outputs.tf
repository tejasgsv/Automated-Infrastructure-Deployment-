output "vm_name" {
  description = "VM name."
  value       = azurerm_linux_virtual_machine.this.name
}

# admin SSH private key is expected to be managed externally and supplied as a public key.
# Keeping this output would require generating a keypair, which is not implemented.
# output "ssh_private_key_pem" {
#   description = "Generated private key for initial access."
#   value       = tls_private_key.this.private_key_pem
#   sensitive   = true
# }
