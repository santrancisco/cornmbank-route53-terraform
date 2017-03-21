##
## The following lines declare all variables and their default values
## If terraform.tfvars exist, it will be loaded and overwrite any of these variable
## To load a seperate tfvar file (you may have a secret.tfvars file, use -var-file="secret.tfvars" switch)
variable "access-key" {}
variable "secret-key" {}
variable "bucket-name" {
  default="YOUR-BUCKET-NAME"
}
variable "bucket-key" {
  default="PATH/route53/"
}
variable "bucket-region" {
  default="ap-southeast-2"
}

data "terraform_remote_state" "state" {
    backend = "s3"
    config {
        bucket = "${var.bucket-name}"
        key = "${var.bucket-key}/terraform.tfstate"
        region = "${var.bucket-region}"
    }
}

provider "aws" {
  access_key = "${var.access-key}"
  secret_key = "${var.secret-key}"
  region     = "us-east-1"
}

variable "bodhi-address" {
  type = "string"
  default = "www.bodhiandpriya.com"
}

variable "ebfe" {
  type = "string"
  default = "107.6.143.150"
}
variable "etherpadbox" {
  type = "string"
  default = "162.248.10.97"
}
variable "throwawaybox" {
  type = "string"
  default = "104.233.105.173"
}

# Define our primary zone

resource "aws_route53_zone" "cornmbank-main" {
  name    = "cornmbank.com"
  comment = "San's playground"
}

# Define a subdomain zone - Usually at this step in console, we will note down the NS servers
# for the subdomain to help with next step

resource "aws_route53_zone" "cornmbank-dev" {
  name = "dev.cornmbank.com"
  comment = "San's playground 2"
  tags {
    Enabled = "false"
  }
}

# This is how we can create NS record for our subdomain zone in the primary zone
# (Notice the record is create in cornmbank-main & the 4 records are from dev zone.)
# Usually in the console, this involve copy-pasta these NS server addresses.

resource "aws_route53_record" "cornmbank-dev-ns" {
  zone_id = "${aws_route53_zone.cornmbank-main.zone_id}"
  name    = "dev.cornmbank.com"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.cornmbank-dev.name_servers.0}",
    "${aws_route53_zone.cornmbank-dev.name_servers.1}",
    "${aws_route53_zone.cornmbank-dev.name_servers.2}",
    "${aws_route53_zone.cornmbank-dev.name_servers.3}",
  ]
}

resource "aws_route53_record" "root" {
  zone_id = "${aws_route53_zone.cornmbank-main.zone_id}"
  name    = "cornmbank.com"
  type    = "A"
  ttl     = "300"
  records = ["${var.ebfe}"]
}

resource "aws_route53_record" "throwaway" {
  zone_id = "${aws_route53_zone.cornmbank-main.zone_id}"
  name    = "throwaway.cornmbank.com"
  type    = "A"
  ttl     = "300"
  records = ["${var.throwawaybox}"]
}

resource "aws_route53_record" "etherpad" {
  zone_id = "${aws_route53_zone.cornmbank-main.zone_id}"
  name    = "etherpad.cornmbank.com"
  type    = "A"
  ttl     = "300"
  records = ["${var.etherpadbox}"]
}

resource "aws_route53_record" "shout" {
  zone_id = "${aws_route53_zone.cornmbank-main.zone_id}"
  name    = "shout.cornmbank.com"
  type    = "A"
  ttl     = "300"
  records = ["${var.etherpadbox}"]
}


resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.cornmbank-main.zone_id}"
  name    = "www.cornmbank.com"
  type    = "A"
  ttl     = "300"
  records = ["${var.ebfe}"]
}

resource "aws_route53_record" "txt" {
  zone_id = "${aws_route53_zone.cornmbank-main.zone_id}"
  name    = "cornmbank.com"
  type    = "TXT"
  ttl     = "300"
  records = ["Hello Word"]
}

resource "aws_route53_record" "scripttxt" {
  zone_id = "${aws_route53_zone.cornmbank-dev.zone_id}"
  name    = "dev.cornmbank.com"
  type    = "TXT"
  ttl     = "300"
  records = ["<script>alert(1);</script>"]
}

resource "aws_route53_record" "bodhi" {
  zone_id = "${aws_route53_zone.cornmbank-main.zone_id}"
  name    = "bodhi.cornmbank.com."
  type    = "CNAME"
  ttl     = "300"
  records = ["${var.bodhi-address}"]
  provisioner "local-exec" {
    command = "echo This provisioner script runs only at creation of bodhi CNAME record =)."
    on_failure = "continue"
  }
  provisioner "local-exec" {
    command = "echo And This provisioner script runs at destruction of bodhi CNAME record =)."
    on_failure = "continue"
    when = "destroy"
  }
}
