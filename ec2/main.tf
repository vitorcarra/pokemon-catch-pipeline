resource "aws_iam_instance_profile" "ssm-profile" {
  name = "ssm_profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "ssm_enable_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

data "aws_iam_policy" "ssm_policy" {
  name = "AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.ssm_policy.arn
}


resource "aws_instance" "data-instance" {
	ami = "ami-0c2b8ca1dad447f8a"
	instance_type = "t2.small"
    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.ssm-profile.name

    vpc_security_group_ids      = ["${var.security_group_id}"]
    subnet_id                   = "${var.subnet_id}"

	# user_data = "${file("user_data/setup.sh")}"
    user_data=<<EOF
#! /bin/bash
sudo yum update
sudo yum install -y https://s3.${var.region}.amazonaws.com/amazon-ssm-${var.region}/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl status amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo systemctl status amazon-ssm-agent
sudo yum -y install ec2-instance-connect
sudo yum -y install java-1.8.0
sudo wget https://archive.apache.org/dist/kafka/2.2.1/kafka_2.12-2.2.1.tgz
sudo tar -xzf kafka_2.12-2.2.1.tgz
sudo kafka_2.12-2.2.1/bin/kafka-topics.sh --create --zookeeper "${var.zookeeper_connect_string}" --replication-factor 2 --partitions 1 --topic ${var.kafka_topic}


# logstash
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo tee -a /etc/yum.repos.d/logstash.repo > /dev/null <<CONF /etc/yum.repos.d/logstash.repo
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
CONF
sudo yum -y install logstash
sudo usermod -a -G logstash ec2-user

mkdir settings
cat<<CONF >> settings/logstash_kafka.config
input {
  kafka {
    bootstrap_servers => "${var.kafka_bootstrap_servers}"
    topics => ["${var.kafka_topic}"]
    codec => json
    security_protocol => "SSL"
  }
}

output {
    elasticsearch {
      hosts => ["${var.elastichost}"]
      index => "pokemon-catches-index"
    }
    stdout {
      codec => rubydebug
    }
}
CONF

sudo nohup /usr/share/logstash/bin/logstash -f settings/logstash_kafka.config &
EOF
	tags = {
		project_name = var.project_name	
	}
}
