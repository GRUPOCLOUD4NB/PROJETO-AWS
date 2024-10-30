# outputs.tf

output "local_files_bucket_name" {
  description = "Nome do bucket S3 local-files"
  value       = aws_s3_bucket.local_files.bucket
}

output "bronze_bucket_name" {
  description = "Nome do bucket S3 bronze"
  value       = aws_s3_bucket.bronze.bucket
}

output "silver_bucket_name" {
  description = "Nome do bucket S3 silver"
  value       = aws_s3_bucket.silver.bucket
}

output "gold_bucket_name" {
  description = "Nome do bucket S3 gold"
  value       = aws_s3_bucket.gold.bucket
}

output "sns_topic_arn" {
  description = "ARN do tópico SNS para notificações"
  value       = aws_sns_topic.file_upload_notifications.arn
}

output "sqs_queue_url" {
  description = "URL da fila SQS para notificações de upload"
  value       = aws_sqs_queue.file_upload_queue.id
}
