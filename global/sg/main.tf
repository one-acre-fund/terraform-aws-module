# ---------------------------
# Security Group
# ---------------------------
resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description      = lookup(ingress.value, "description", null)
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = length(coalesce(lookup(ingress.value, "security_groups", []), [])) > 0 ? [] : coalesce(lookup(ingress.value, "cidr_blocks", []), [])
      security_groups  = coalesce(lookup(ingress.value, "security_groups", []), [])
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description      = lookup(egress.value, "description", null)
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = length(coalesce(lookup(egress.value, "security_groups", []), [])) > 0 ? [] : coalesce(lookup(egress.value, "cidr_blocks", []), [])
      security_groups  = coalesce(lookup(egress.value, "security_groups", []), [])
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    }
  }

  tags = merge(local.common_tags, {
    Name = var.name
  })
}