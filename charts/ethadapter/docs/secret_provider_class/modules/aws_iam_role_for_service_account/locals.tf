locals {
  oidc_issuer_path = replace(var.oidc_provider_url, "https://", "")
  flatList         = join(",", var.service_accounts)
  replacedList = replace(
    replace(local.flatList, "/", ":"),
    "system:serviceaccount:",
    "",
  )
  serviceAccountList = formatlist("system:serviceaccount:%s", split(",", local.replacedList))
}
