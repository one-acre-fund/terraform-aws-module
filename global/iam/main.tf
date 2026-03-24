# ---------------------------
# IAM Role
# ---------------------------
resource "aws_iam_role" "this" {
  name               = var.role_name
  description        = var.role_description
  assume_role_policy = var.assume_role_policy

  tags = merge(local.common_tags, {
    Name = var.role_name
  })
}

# ---------------------------
# Custom IAM Policy
# ---------------------------
resource "aws_iam_policy" "this" {
  count = var.create_policy ? 1 : 0

  name        = var.policy_name
  description = var.policy_description
  policy      = var.policy_document

  tags = merge(local.common_tags, {
    Name = var.policy_name
  })
}

# ---------------------------
# Attach Custom Policy to Role
# ---------------------------
resource "aws_iam_role_policy_attachment" "custom" {
  count = var.create_policy ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this[0].arn
}

# ---------------------------
# Attach Managed Policies to Role
# ---------------------------
resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# ---------------------------
# IAM Instance Profile
# ---------------------------
resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = var.role_name
  role = aws_iam_role.this.name

  tags = merge(local.common_tags, {
    Name = var.role_name
  })
}
