vault server -config /opt/vault.hcl &

set -x

sleep 3

# check if need init
if [ $(curl -s http://localhost:8200/v1/sys/seal-status | jq -r ".initialized") = "false" ] 
then
	VAULT_ADDR="http://localhost:8200" vault operator init --format=json > /tmp/vault-init.json

	aws s3 cp /tmp/vault-init.json s3://$BL_VAULT_CONFIG_S3_BUCKET/vault-init.json
else
	sleep 5
fi

# Download keys
aws s3 cp s3://$BL_VAULT_CONFIG_S3_BUCKET/vault-init.json /tmp/vault-init.json

# unseal
cat /tmp/vault-init.json | jq  -r ".unseal_keys_b64[]" | while read KEY; do
    VAULT_ADDR="http://localhost:8200" vault operator unseal $KEY
done

rm /tmp/vault-init.json

tail -f /dev/null