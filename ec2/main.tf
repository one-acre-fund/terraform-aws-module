# ---------------------------
# EC2 Instance
# ---------------------------
resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  monitoring                  = var.monitoring
  user_data                   = var.user_data

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = var.root_volume_name
    })
  }

  tags = merge(local.common_tags, {
    Name = var.instance_name
  })

  lifecycle {
    ignore_changes = [ami]
  }
}
