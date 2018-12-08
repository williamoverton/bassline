# Bassline
##### A baseline project for deploying all the things

------

## What's Included?
- VPC creation.
- Bations for secure access
- Squid Proxy for outbound connections
- Vault cluster for secure secret storage & more
- Aurora Mysql Database in secure vpc
- Elasticsearch service for log/analytic storage

## How do I setup terraform?
- Either create an S3 bucket for terraform state
- Automatically create a bucket by running the setup script: `./setup/setup_terraform.sh`

## How do I deploy everything?
1. Authenticate with AWS (this will differ depending on your environment. run `aws configure` for basic key based auth
2. Run the `deploy-${env}.sh` script, e.g. `./deploy-dev.sh`

## How do I deploy just what I need?
1. Move into / create the directory matching what you want to release, e.g. `cd vpc/terraform/instances/dev-eu-west-1`
2. Authenticate with AWS (this will differ depending on your environment. run `aws configure` for basic key based auth
3. Run `terraform apply` to deploy

## How secure is this setup?
- Two VPCs are created, one public and one private. Only the public VPC can access the internet without using the proxy
- All service secrets are stored in AWS Secret Manager (as well as terraform state, meaning you should make sure only trusted users can access this)
