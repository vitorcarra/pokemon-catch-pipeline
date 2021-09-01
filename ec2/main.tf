resource "aws_instance" "my-instance" {
	ami = "ami-0c2b8ca1dad447f8a"
	instance_type = "t2.micro"

    vpc_security_group_ids      = ["${var.security_group_id}"]
    subnet_id                   = "${var.subnet_id}"

	# user_data = "${file("user_data/setup.sh")}"
    user_data=<<EOF
#! /bin/bash
sudo apt-get update
sudo yum install ec2-instance-connect
sudo yum install java-1.8.0
wget https://archive.apache.org/dist/kafka/2.2.1/kafka_2.12-2.2.1.tgz
tar -xzf kafka_2.12-2.2.1.tgz
kafka_2.12-2.2.1/bin/kafka-topics.sh --create --zookeeper "${var.zookeeper_connect_string}" --replication-factor 3 --partitions 1 --topic ${var.kafka_topic}
EOF
	tags = {
		project_name = var.project_name	
	}
}