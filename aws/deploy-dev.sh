echo "Deploying everything in dev!"

BL_PATH=`pwd`

cd vpc/terraform/instances/dev-eu-west-1/
terraform apply -auto-approve

cd $BL_PATH

cd bastion/terraform/instances/dev-eu-west-1-sandbox/
terraform apply -auto-approve

cd $BL_PATH

cd proxy/terraform/instances/dev-eu-west-1-sandbox/
terraform apply -auto-approve

cd $BL_PATH

cd vault/terraform/instances/dev-eu-west-1-sandbox/
terraform apply -auto-approve

cd $BL_PATH

cd aurora/terraform/instances/dev-eu-west-1-sandbox/
terraform apply -auto-approve

cd $BL_PATH

cd check_mk/terraform/instances/dev-eu-west-1-sandbox/
terraform apply -auto-approve

cd $BL_PATH

echo "Done!"