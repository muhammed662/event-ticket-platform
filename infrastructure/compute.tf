data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = [
    "amazon",
  ]

  filter {
    name = "name"

    values = [
      "al2023-ami-2023.*-x86_64",
    ]
  }

  filter {
    name = "architecture"

    values = [
      "x86_64",
    ]
  }

  filter {
    name = "root-device-type"

    values = [
      "ebs",
    ]
  }

  filter {
    name = "virtualization-type"

    values = [
      "hvm",
    ]
  }
}


resource "aws_launch_template" "backend" {
  name_prefix = "${var.project_name}-backend-"

  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.ec2_instance_type

  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.backend.name
  }

  vpc_security_group_ids = [
    aws_security_group.ec2.id,
  ]

  user_data = base64encode(
    templatefile(
      "${path.module}/user_data.sh.tftpl",
      {
        artifact_bucket = aws_s3_bucket.artifacts.id
        artifact_key    = aws_s3_object.backend.key

        aws_region    = var.aws_region
        db_secret_arn = aws_db_instance.postgres.master_user_secret[0].secret_arn
        db_host       = aws_db_instance.postgres.address
        db_port       = aws_db_instance.postgres.port
        db_name       = aws_db_instance.postgres.db_name
      }
    )
  )

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  monitoring {
    enabled = false
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-backend"
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name        = "${var.project_name}-backend-volume"
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  depends_on = [
    aws_iam_role_policy.backend_access,
    aws_iam_role_policy_attachment.ssm,
    aws_s3_object.backend,
  ]

  tags = {
    Name = "${var.project_name}-backend-template"
  }
}