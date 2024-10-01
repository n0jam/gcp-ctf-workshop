#! /bin/bash

PROJECT_ID=$(curl -s http://metadata.google.internal/computeMetadata/v1/project/project-id -H "metadata-flavor:Google")

# sending heartbeat to compute monitoring function"
FUNCTION_RESPONSE=$(curl -s -X POST https://europe-west1-$PROJECT_ID.cloudfunctions.net/challenge4-function -H "Authorization: bearer $(gcloud auth print-identity-token)" -H "Content-Type: application/json" -d '{"metadata": "email"}')

echo $FUNCTION_RESPONSE