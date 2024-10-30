# main.tf

# Provedor AWS
provider "aws" {
  region = var.aws_region
}

# Buckets S3: local-files, bronze, silver, e gold
resource "aws_s3_bucket" "local_files" {
  bucket = "local-files-bucket-unique-name"
}

resource "aws_s3_bucket" "bronze" {
  bucket = "bronze-bucket-unique-name"
}

resource "aws_s3_bucket" "silver" {
  bucket = "silver-bucket-unique-name"
}

resource "aws_s3_bucket" "gold" {
  bucket = "gold-bucket-unique-name"
}

# Configuração de versionamento para cada bucket
resource "aws_s3_bucket_versioning" "local_files_versioning" {
  bucket = aws_s3_bucket.local_files.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "bronze_versioning" {
  bucket = aws_s3_bucket.bronze.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "silver_versioning" {
  bucket = aws_s3_bucket.silver.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "gold_versioning" {
  bucket = aws_s3_bucket.gold.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# Tópico SNS para notificação
resource "aws_sns_topic" "file_upload_notifications" {
  name = "file-upload-notifications-topic"
}

# Política do SNS para permitir notificações do S3
resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn    = aws_sns_topic.file_upload_notifications.arn
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "sns:Publish",
        Resource  = aws_sns_topic.file_upload_notifications.arn,
        Condition = {
          ArnLike = {
            "aws:SourceArn": [
              aws_s3_bucket.bronze.arn,
              aws_s3_bucket.silver.arn,
              aws_s3_bucket.gold.arn
            ]
          }
        }
      }
    ]
  })
}

# Fila SQS para receber notificações
resource "aws_sqs_queue" "file_upload_queue" {
  name = "file-upload-queue"
}

# Inscrição da fila SQS no tópico SNS
resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn = aws_sns_topic.file_upload_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.file_upload_queue.arn
}

# Política para permitir que o SNS envie mensagens para a SQS
resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.file_upload_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "sqs:SendMessage"
        Resource = aws_sqs_queue.file_upload_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn": aws_sns_topic.file_upload_notifications.arn
          }
        }
      }
    ]
  })
}

# Configuração de eventos do S3 para acionar o SNS quando novos arquivos forem adicionados
resource "aws_s3_bucket_notification" "bronze_notification" {
  bucket = aws_s3_bucket.bronze.id
  topic {
    topic_arn = aws_sns_topic.file_upload_notifications.arn
    events    = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_sns_topic_policy.sns_topic_policy]
}

resource "aws_s3_bucket_notification" "silver_notification" {
  bucket = aws_s3_bucket.silver.id
  topic {
    topic_arn = aws_sns_topic.file_upload_notifications.arn
    events    = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_sns_topic_policy.sns_topic_policy]
}

resource "aws_s3_bucket_notification" "gold_notification" {
  bucket = aws_s3_bucket.gold.id
  topic {
    topic_arn = aws_sns_topic.file_upload_notifications.arn
    events    = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_sns_topic_policy.sns_topic_policy]
}
