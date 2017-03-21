# What is this?

This is my terraform code to provision/config route53 for my cornmbank.com site. It's my playground to learn terraform. If it helps you, great. And yes, having this file is like doing zone transfer on my cornmbank `dig AXFR cornmbank.com`  but I don't mind as it's nothing sensitive :)

For this task, i created a new user in AWS with full access to Route53 policy attached.

I also created a S3 bucket folder with Infrequent Usage, AES256 encryption to store the tfstate files and make it easier to manage route53 in different machines.

Below is a custom IAM policy you can attach to your custom group for any account doing Route53 changes. This policy let user has full access to particular S3 bucket folder which contains the tfstate file.

To verify this is working, using the aws-cli with the specified user credential, run this aws command: `aws s3 ls s3://OUR-S3-BUCKET-NAME/PATH-TO/route53/`. 

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAllS3ActionsInRoute53Folder",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::YOUR-S3-BUCKET-NAME/PATH-TO/route53/*"
            ]
        }
    ]
}
```


Create a config.tf file with the following content
```
terraform {
  backend "s3" {
    bucket = "YOUR-S3-BUCKET-NAME"
    key    = "PATH-TO/route53/route53.tfstate"
    region = "REGION-OF-BUCKET"
  }
}

```

To finalise the configuration and make sure terraform will use s3 bucket for its state, run `terraform init`. you should now see a .terraform folder being created. 
NOTE: You may need working AWS-cli installed with accesskey and secret for this user account configured. I have not tested it without this credential pre-set.

Now you can start playing with cornmbank DNS!
