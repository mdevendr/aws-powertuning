resource "aws_s3_bucket" "tuning_reports" {
  bucket = "${var.project}-tuning-reports"
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tuning_reports.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.tuning_reports.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_iam_policy" "report_writer" {
  name        = "${var.project}-report-writer"
  description = "Allows GitHub CI to upload tuning reports to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:PutObjectAcl"]
        Resource = "arn:aws:s3:::${aws_s3_bucket.tuning_reports.bucket}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_report_writer" {
  role       = var.github_oidc_role
  policy_arn = aws_iam_policy.report_writer.arn
}
