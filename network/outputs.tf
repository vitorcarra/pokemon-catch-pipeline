output "vpc_security_group_ids" {
    value = [aws_security_group.default.id]
}

output "private_subnet_group_id1" {
    value = aws_subnet.private1.id
}

output "private_subnet_group_id2" {
    value = aws_subnet.private2.id
}

output "vpc_id" {
    value = aws_vpc.main.id
}