cluster_name = "bl-vault"

listener "tcp" {
  address = "0.0.0.0:8200"
}

storage "dynamodb" {
  ha_enabled = "true"
}
