output "nat_gateway_ids" {
  value       = aws_nat_gateway.this[*].id
  description = "List of NAT gateway ids (empty if nat_mode != gateway)"
}

output "nat_instance_id" {
  value       = var.nat_mode == "instance" && length(aws_instance.nat_instance) > 0 ? aws_instance.nat_instance[0].id : ""
  description = "NAT instance id (empty if nat_mode != instance)"
}

output "nat_instance_primary_network_interface_id" {
  value       = var.nat_mode == "instance" && length(aws_instance.nat_instance) > 0 ? aws_instance.nat_instance[0].primary_network_interface_id : ""
  description = "Primary network interface id for the NAT instance (useful for routes)"
}

output "nat_eip_ids" {
  value       = aws_eip.nat[*].id
  description = "EIP ids allocated for NAT gateways"
}
