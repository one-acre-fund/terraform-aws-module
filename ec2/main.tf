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
      Name = local.volume_names[count.index]
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

    precondition {
      condition     = !var.enable_eip || var.enable_public
      error_message = "enable_eip requires enable_public = true so the instance is placed in a public subnet with an IGW route."
    }

    ignore_changes = [ami]
  }
}

# ---------------------------
# Additional EBS Volumes
# ---------------------------
resource "aws_ebs_volume" "additional" {
  for_each = local.additional_volume_map

  availability_zone = aws_instance.this[each.value.instance_index].availability_zone
  size              = each.value.vol.size
  type              = each.value.vol.type
  encrypted         = each.value.vol.encrypted
  iops              = each.value.vol.iops
  throughput        = each.value.vol.throughput

  tags = merge(local.common_tags, {
    Name = "vol-${each.value.app_name}-${var.environment}-${format("%02d", each.value.vol_number)}"
  })
}

resource "aws_volume_attachment" "additional" {
  for_each = local.additional_volume_map

  device_name = each.value.vol.device_name
  volume_id   = aws_ebs_volume.additional[each.key].id
  instance_id = aws_instance.this[each.value.instance_index].id
}

# ---------------------------
# Elastic IPs
# ---------------------------
resource "aws_eip" "this" {
  count  = var.enable_eip ? var.instance_count : 0
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "eip-${var.environment}-${var.application}-${format("%02d", count.index + 1)}"
  })
}

resource "aws_eip_association" "this" {
  count         = var.enable_eip ? var.instance_count : 0
  instance_id   = aws_instance.this[count.index].id
  allocation_id = aws_eip.this[count.index].id
}
