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

  # Mutually exclusive: use SG source OR cidr_blocks, never both
  cidr_blocks = (
    length(coalesce(lookup(each.value, "security_groups", []), [])) > 0
    ? null
    : coalesce(lookup(each.value, "cidr_blocks", []), [])
  )

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

  # Mutually exclusive: use SG source OR cidr_blocks, never both
  cidr_blocks = (
    length(coalesce(lookup(each.value, "security_groups", []), [])) > 0
    ? null
    : coalesce(lookup(each.value, "cidr_blocks", []), [])
  )

  source_security_group_id = (
    length(coalesce(lookup(each.value, "security_groups", []), [])) > 0
    ? lookup(each.value, "security_groups", [])[0]
    : null
  )
}