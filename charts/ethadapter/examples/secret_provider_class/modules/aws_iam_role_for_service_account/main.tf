data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "AssumeableByOIDC"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringLike"
      variable = "${local.oidc_issuer_path}:sub"
      values   = local.serviceAccountList
    }

    principals {
      identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/${local.oidc_issuer_path}"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "main" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.tags
}

# Add inline policies
resource "aws_iam_role_policy" "main" {
  count = length(var.inline_policies)

  name   = "inline-policy-${count.index}"
  role   = aws_iam_role.main.id
  policy = element(var.inline_policies, count.index)

  lifecycle {
    create_before_destroy = true
  }
}

# Attach existing IAM policies
resource "aws_iam_role_policy_attachment" "main" {
  for_each   = toset(var.policy_arns)
  policy_arn = each.key
  role       = aws_iam_role.main.id
}