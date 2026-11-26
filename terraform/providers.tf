provider "hcloud" {
  # Prefer exporting TF_VAR_hcloud_token over writing the token into a
  # tfvars file.
  token = var.hcloud_token
}
