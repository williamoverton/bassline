
export AWS_DYNAMODB_TABLE="{{dynamodb_table_name}}"
export AWS_REGION="{{aws_region}}"

vault server -config /opt/vault.hcl
