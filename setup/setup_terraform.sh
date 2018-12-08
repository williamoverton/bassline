#!/bin/bash

echo "Please enter a region. (You do not need a different state bucket per region) [eu-west-1]"
read region

# Set default
region="${region:-eu-west-1}"

if [ $region != "eu-west-1" ]
then
	echo "WARNING! You will need to change all terrafrom remote state regions if you dont choose eu-west-1"
fi

echo "Creating bucket..."

if [ $region == "us-east-1" ]
then
	aws --region $region s3api create-bucket --bucket bl-terrafrom-remote-state > /dev/null
else
	aws --region $region s3api create-bucket --bucket bl-terrafrom-remote-state --create-bucket-configuration LocationConstraint="$region" > /dev/null
fi

echo "Done!"