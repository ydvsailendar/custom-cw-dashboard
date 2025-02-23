aws s3api create-bucket --bucket observcw01 --profile sandbox --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2
aws s3api put-bucket-versioning --bucket observcw01 --versioning-configuration Status=Enabled --profile sandbox --region eu-west-2
