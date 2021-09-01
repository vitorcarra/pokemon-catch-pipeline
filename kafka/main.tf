resource "aws_kms_key" "kms" {
  description = "kms-msk"
}

resource "aws_cloudwatch_log_group" "msk_log_group" {
  name = "msk_broker_logs"
}

resource "aws_s3_bucket" "msk_logs_bucket" {
  bucket = "peg-msk-broker-logs-bucket"
  acl    = "private"
}

resource "aws_msk_cluster" "msk_pokemon" {
  cluster_name           = "msk-cluster-pokemon"
  kafka_version          = "2.6.2"
  number_of_broker_nodes = 2
  

  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    ebs_volume_size = 20
    client_subnets = [
      var.subnet_az1,
      var.subnet_az2,
    ]
    security_groups = [var.kafka_sg]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn
  }


  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_log_group.name
      }
      s3 {
        enabled = true
        bucket  = aws_s3_bucket.msk_logs_bucket.id
        prefix  = "logs/msk-"
      }
    }
  }

  tags = {
    project_name = var.project_name
  }
}