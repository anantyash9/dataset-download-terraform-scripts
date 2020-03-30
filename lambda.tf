provider "aws" {
   region = "us-east-1"
 }

  resource "aws_iam_role" "lambda_exec" {
   name = "serverless_downloader"

   assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Action": "sts:AssumeRole",
       "Principal": {
         "Service": "lambda.amazonaws.com"
       },
       "Effect": "Allow",
       "Sid": ""
     }
   ]
}
EOF

 }


 resource "aws_iam_policy" "s3_access" {
  name = "s3_access_for_lambda"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "${aws_iam_policy.s3_access.arn}"
}

module lambda {
  source = "github.com/terraform-module/terraform-aws-lambda?ref=v2.4.0"

  function_name      = "downloader"
  filename           = "function.zip"
  description        = "distributed serverless downoader"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.6"
  memory_size        = "128"
  concurrency        = "50"
  lambda_timeout     = "180"
  log_retention      = "1"
  role_arn = aws_iam_role.lambda_exec.arn

  tags = {
    Environment = "test"
  }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "dataset-bucket-anant9"
  acl    = "private"

  versioning = {
    enabled = true
  }

}
