# README

## Command

```bash
# create s3 bucket
aws s3api create-bucket --bucket <bucket_name> --profile <aws_profile_name> --region <aws_region> --create-bucket-configuration LocationConstraint=<aws_region>
```

```bash
# enable versioning in the created bucket
aws s3api put-bucket-versioning --bucket <bucket_name> --versioning-configuration Status=Enabled --profile <aws_profile_name> --region <aws_region>
```

## TODO

Ensure you create a bucket with the same name specificed in the backend.tf for the bucket and make sure your bucket is unique
