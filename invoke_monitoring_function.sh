#! /bin/bash

# sending heartbeat to compute monitoring function"
FUNCTION_RESPONSE=$(curl -s -X POST https://$LOCATION-$PROJECT_ID.cloudfunctions.net/monitoring-function -H "Authorization: bearer $(gcloud auth print-identity-token)" -H "Content-Type: application/json" -d '{"metadata": "email"}')

echo $FUNCTION_RESPONSE
