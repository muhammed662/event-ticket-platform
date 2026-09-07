data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}


resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Controls traffic to the application load balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}


resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allows backend traffic only from the ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}


resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Allows PostgreSQL traffic only from EC2"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cloudfront_to_alb" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP traffic from CloudFront"

  prefix_list_id = data.aws_ec2_managed_prefix_list.cloudfront.id
  from_port      = 80
  to_port        = 80
  ip_protocol    = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ec2" {
  security_group_id = aws_security_group.alb.id
  description       = "Backend traffic from ALB to EC2"

  referenced_security_group_id = aws_security_group.ec2.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}


resource "aws_vpc_security_group_ingress_rule" "alb_to_ec2" {
  security_group_id = aws_security_group.ec2.id
  description       = "FastAPI traffic from ALB"

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ec2_outbound" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow EC2 outbound traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "ec2_to_rds" {
  security_group_id = aws_security_group.rds.id
  description       = "PostgreSQL traffic from EC2"

  referenced_security_group_id = aws_security_group.ec2.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}