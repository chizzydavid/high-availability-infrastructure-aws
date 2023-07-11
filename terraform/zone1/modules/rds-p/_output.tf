output "db_cluster_arn" {
  value = aws_rds_cluster.udacity_cluster.arn
}

output "db_instance_arn" {
  value = aws_rds_cluster_instance.udacity_instance[0].arn
}
