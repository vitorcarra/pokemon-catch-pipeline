data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

variable "domain" {
  default = "es-pokemon-cluster"
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.domain
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type          = "t3.medium.elasticsearch"
    zone_awareness_enabled = false
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  # vpc_options {
  #   subnet_ids = [
  #     var.public_subnet_group_id1
  #   ]

  #   security_group_ids = [var.default_sg]
  # }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:ESHttp*",
      "Resource": "arn:aws:es:us-east-1:527562940573:domain/es-pokemon-cluster/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": ["${var.allow_ip_address}", "192.168.0.0/16"]
        }
      }
    }
  ]
}
CONFIG

  depends_on = [aws_iam_service_linked_role.es]
}