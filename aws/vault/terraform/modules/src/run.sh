export VAULT_CLUSTER_ADDR="http://$(curl http://169.254.169.254/latest/meta-data/local-ipv4):8200"

vault server -config /opt/vault.hcl &

set -x

env

sleep 3

# check if need init
if [[ $(curl -s http://localhost:8200/v1/sys/seal-status | jq -r ".initialized") = "false" ]]
then
	VAULT_ADDR="http://localhost:8200" vault operator init --format=json > /tmp/vault-init.json

	aws s3api put-object --body /tmp/vault-init.json --bucket $BL_VAULT_CONFIG_S3_BUCKET --key vault-init.json
else
	sleep 5
fi

# Download keys
aws s3api get-object --bucket $BL_VAULT_CONFIG_S3_BUCKET --key vault-init.json /tmp/vault-init.json

# unseal
cat /tmp/vault-init.json | jq  -r ".unseal_keys_b64[]" | while read KEY; do
    VAULT_ADDR="http://localhost:8200" vault operator unseal $KEY
done

rm /tmp/vault-init.json

tail -f /dev/null