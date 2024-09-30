module "template_files" {
    source = "hashicorp/dir/template"

    base_dir = "${path.module}/web"
}


resource "aws_s3_bucket" "name" {
  bucket = var.bucket_name
}

# Disable Block Public Access to allow public policies
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.name.id

  block_public_acls       = false  # Allows public ACLs
  block_public_policy     = false  # Allows public bucket policies
  ignore_public_acls      = false  # Allows public ACLs to be ignored
  restrict_public_buckets = false  # Does not restrict public bucket policies
}

# Add bucket policy to allow public read access to objects in the bucket
resource "aws_s3_bucket_policy" "hosting_bucket_policy" {
  bucket = aws_s3_bucket.name.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.name.bucket}/*"  # Correct bucket reference
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "hosting_bucket_website_configuration" {
  bucket = aws_s3_bucket.name.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"  # Specify your error document
  }
}

resource "aws_s3_object" "hosting_bucket_files" {
  bucket = aws_s3_bucket.name.id

  for_each = module.template_files.files

  key          = each.key
  source       = each.value.source_path
  content_type = each.value.content_type

  # Optional: Consider removing content if not needed
  content      = each.value.content
}
