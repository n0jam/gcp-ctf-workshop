#! /bin/bash

# variables
read -p "Your GCP project ID: " PROJECT_ID
ZONE=europe-west1-b
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID | grep projectNumber | tr -d -c 0-9)

# destroy resources with terraform
cd terraform
terraform destroy -var project-id="$PROJECT_ID" -var project-number="$PROJECT_NUMBER" -auto-approve
cd ../

# destroy resources for challenge 3 with terraform
cd terraform_challenge3
terraform destroy -var project-id="$PROJECT_ID" -var project-number="$PROJECT_NUMBER" -auto-approve
cd ../

# clean up credential files we created
rm ./leaked_ssh_key ./leaked_ssh_key.pub challenge1-creds.json
