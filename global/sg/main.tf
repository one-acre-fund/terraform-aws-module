resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = var.name
  })
}

# Ingress rules
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

  cidr_blocks = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = (
    length(lookup(each.value, "security_groups", [])) > 0
    ? each.value.security_groups[0]
    : null
  )
}

# Egress rules
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

  cidr_blocks = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = (
    length(lookup(each.value, "security_groups", [])) > 0
    ? each.value.security_groups[0]
    : null
  )
}