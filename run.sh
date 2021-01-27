#!/bin/bash

name_secret="Compute-Engine-2"
$PROJECT_ID="burnished-case-280710"

mkdir -p ./creds 

#  Add secret "Compute-Engine-1" to /security/secret-manager
#  Enable "Secret Manager" in cloud-build/settings
gcloud secrets versions access latest --secret=$name_secret --format='get(payload.data)' | tr '_-' '/+' | base64 -d > ./creds/serviceaccount.json

gcloud auth activate-service-account --key-file ./creds/serviceaccount.json



function Image_exists() {
    curl --silent -f -lSL https://gcr.io/$PROJECT_ID/terragrunt:latest > /dev/null 

}

if Image_exists; then
    echo "Image exist,...."
    echo "pulling existing Image..."
else 
    echo " image not exist remotly...."
    echo "Building  image..."
   gcloud builds submit . --config=./terragrunt-cloudbuild.yml
fi