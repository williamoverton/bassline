echo "Destroying everything in dev!"

BL_PATH=`pwd`

cd vault/terraform/instances/dev-eu-west-1-sandbox/
terraform destroy -auto-approve

cd $BL_PATH

cd proxy/terraform/instances/dev-eu-west-1-sandbox/
terraform destroy -auto-approve

cd $BL_PATH

cd vpc/terraform/instances/dev-eu-west-1/
terraform destroy -auto-approve

cd $BL_PATH

echo "Done!"