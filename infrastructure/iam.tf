data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}


resource "aws_iam_role" "backend" {
  name = "${var.project_name}-backend-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json

  tags = {
    Name = "${var.project_name}-backend-role"
  }
}

data "aws_iam_policy_document" "backend_access" {
  statement {
    sid    = "DownloadBackendPackage"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_object.backend.arn,
    ]
  }

  statement {
    sid    = "ReadDatabasePassword"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      aws_db_instance.postgres.master_user_secret[0].secret_arn,
    ]
  }
}


resource "aws_iam_role_policy" "backend_access" {
  name = "${var.project_name}-backend-access"
  role = aws_iam_role.backend.id

  policy = data.aws_iam_policy_document.backend_access.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role = aws_iam_role.backend.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "backend" {
  name = "${var.project_name}-backend-profile"
  role = aws_iam_role.backend.name
}