# ---------------------------
# EC2 Instance
# ---------------------------
resource "aws_instance" "this" {
  count = var.instance_count

  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = local.instance_subnets[count.index]
  key_name                    = var.key_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.enable_public
  monitoring                  = var.monitoring
  user_data                   = var.user_data

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = "${local.instance_names[count.index]}-root"
    })
  }

  tags = merge(local.common_tags, {
    Name = local.instance_names[count.index]
  })

  lifecycle {
    precondition {
      condition     = length(var.application_names) == 0 || length(var.application_names) == var.instance_count
      error_message = "application_names must be empty or contain exactly instance_count (${var.instance_count}) elements."
    }

    precondition {
      condition     = var.enable_public ? length(var.public_subnets) >= 2 : length(var.private_subnets) >= 2
      error_message = "At least 2 subnets must be provided in ${var.enable_public ? "public_subnets" : "private_subnets"}."
    }

    ignore_changes = [ami]
  }
}
