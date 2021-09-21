#!/usr/bin/env bash

set -e
cd ./aws/us-east-1/rds
terraform init

terraform plan \
   -var-file="./development.tfvars" \
   -out="./terraform.tfplan" \
   -input=false 

echo "Please review the plan and type 'yes' to continue:"
read -r inputvar
if [[ $inputvar == "yes" ]]; then
   echo "launching"
   terraform apply \
         -input=false \
         "./terraform.tfplan"
fi