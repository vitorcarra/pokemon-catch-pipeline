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

#   access_policies = <<CONFIG
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "es:*",
#             "Principal": "*",
#             "Effect": "Allow",
#             "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*"
#         }
#     ]
# }
# CONFIG

  depends_on = [aws_iam_service_linked_role.es]
}