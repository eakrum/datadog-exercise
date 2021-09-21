#!/usr/bin/env bash

set -e
cd ./aws/us-east-1/rds
terraform init

terraform plan -destroy\
   -var-file="./development.tfvars" \
   -out="./terraform.tfplan" \
   -input=false 

echo "Please review the plan to destoy and type 'yes' to continue:"
read -r inputvar
if [[ $inputvar == "yes" ]]; then
   echo "destroying"
   terraform apply \
         -input=false \
         "./terraform.tfplan"
fi