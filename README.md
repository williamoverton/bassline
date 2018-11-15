# bassline
##### A baseline project for deploying all the things

------

## What's Included?
- VPC creation.
- Squid Proxy for outbound connections
- Vault cluster for secure secret storage & more
- Aurora Mysql Database in secure vpc

## How do I dpeloy everything?
1. Authenticate with AWS (this will differ depending on your environment. run `aws configure` for basic key based auth
2. Run the `deploy-${env}.sh` script, e.g. `./deploy-dev.sh`

## How do I deploy just what I need?
1. Move into / create the directory matching what you want to release, e.g. `cd vpc/terraform/instances/dev-eu-west-1`
2. Authenticate with AWS (this will differ depending on your environment. run `aws configure` for basic key based auth
3. Run `terraform apply` to deploy
