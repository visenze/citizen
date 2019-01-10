provider "aws" {
  version = "~> 1.54"
}

provider "helm" {
  version = "~> 0.7"
}

provider "template" {
  version = "~> 1.0"
}

provider "kubernetes" {
  version = "~> 1.4"
}

resource "aws_s3_bucket" "storage" {
  bucket = "${var.prefix}citizen"
  acl    = "private"

  tags = {
    App = "Citizen"
  }
}

resource "aws_iam_user" "citizen" {
  name = "${var.prefix}citizen"
}

data "template_file" "iam_policy" {
  template = "${file("${path.module}/iam_s3_policy.json")}"

  vars {
    s3_bucket = "${aws_s3_bucket.storage.bucket}"
  }
}

resource "aws_iam_user_policy" "citizen" {
  user   = "${aws_iam_user.citizen.name}"
  policy = "${data.template_file.iam_policy.rendered}"
}

resource "aws_iam_access_key" "citizen" {
  user = "${aws_iam_user.citizen.name}"
}

resource "kubernetes_secret" "aws_credentials" {
  metadata {
    name = "${var.prefix}citizen-credentials"
  }

  data {
    AWS_ACCESS_KEY_ID     = "${aws_iam_access_key.citizen.id}"
    AWS_SECRET_ACCESS_KEY = "${aws_iam_access_key.citizen.secret}"
  }
}

data "template_file" "helm_values" {
  template = "${file("${path.module}/helm_values.tpl.yaml")}"

  vars {
    s3_bucket   = "${aws_s3_bucket.storage.id}"
    secret_name = "${kubernetes_secret.aws_credentials.metadata.0.name}"
  }
}

resource "helm_release" "citizen" {
  name   = "${var.prefix}citizen"
  chart  = "visenze/citizen"
  values = ["${data.template_file.helm_values.rendered}"]
}
