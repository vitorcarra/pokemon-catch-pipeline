output "zookeeper_connect_string" {
  value = aws_msk_cluster.msk_pokemon.zookeeper_connect_string
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.msk_pokemon.bootstrap_brokers_tls
}