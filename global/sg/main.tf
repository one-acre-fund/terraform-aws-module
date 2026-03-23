# ---------------------------
# Security Group
# ---------------------------
resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = var.name
  })
}

# ---------------------------
# Ingress Rules
# ---------------------------
resource "aws_security_group_rule" "ingress" {
  for_each = {
    for idx, rule in var.ingress_rules : idx => rule
  }

  type              = "ingress"
  security_group_id = aws_security_group.this.id

  description = lookup(each.value, "description", null)
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol

  # Safe handling of optional cidr_blocks
  cidr_blocks = coalesce(lookup(each.value, "cidr_blocks", []), [])

  # Safe handling of optional security_groups
  source_security_group_id = (
    length(coalesce(lookup(each.value, "security_groups", []), [])) > 0
    ? lookup(each.value, "security_groups", [])[0]
    : null
  )
}

# ---------------------------
# Egress Rules
# ---------------------------
resource "aws_security_group_rule" "egress" {
  for_each = {
    for idx, rule in var.egress_rules : idx => rule
  }

  type              = "egress"
  security_group_id = aws_security_group.this.id

  description = lookup(each.value, "description", null)
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol

  # Safe handling of optional cidr_blocks
  cidr_blocks = coalesce(lookup(each.value, "cidr_blocks", []), [])

  # Safe handling of optional security_groups
  source_security_group_id = (
    length(coalesce(lookup(each.value, "security_groups", []), [])) > 0
    ? lookup(each.value, "security_groups", [])[0]
    : null
  )
}