echo "Deploying essentials into dev!"

BL_PATH=`pwd`

cd vpc/terraform/instances/dev-eu-west-1/
terraform init
terraform apply -auto-approve

cd $BL_PATH

cd bastion/terraform/instances/dev-eu-west-1-sandbox/
terraform init
terraform apply -auto-approve

cd $BL_PATH

cd proxy/terraform/instances/dev-eu-west-1-sandbox/
terraform init
terraform apply -auto-approve

cd $BL_PATH

echo "Done!"