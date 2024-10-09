### Challenge 2: State of affairs

You found credentials for a GCP service account.
The json blob already provides some useful information. It contains the GCP project ID, the email of the service account (client_e-mail) and the private key of the account.  

To use the project id in other commands later during this challenge, set it as environment variable:  
#####
    export PROJECT_ID=<project-id>

Save the json blob in a file. You can now also use it as a credential for the gcloud CLI:  
#####
    gcloud auth activate-service-account --key-file <path-to-file>
You can check that this worked when running:  
#####
    gcloud auth list
It now shows the service account as active account.  
So what can you do with this account? Did you find any hints during challenge 1?  
Take another look at the response of the Kubernetes API when you listed the secrets.

#### Useful commands and tools:
- gsutil (already installed with gcloud): `gsutil ls gs://<...>`

#### Hints
<details>
  <summary>Hint 1</summary>

  The kubernetes secret you found in challenge 1 has a label telling you the name of a storage bucket.
  While the service account can't list all storage buckets, it might still have access to this specific bucket.  

</details>

<details>
  <summary>Hint 2</summary>

  The service account key you found on the GKE cluster can access a storage bucket called `file-uploads-$PROJECT_ID`.  
  See what you can find on the bucket by using the `gsutil` command line utility.  
  #####
    gsutil ls gs://<bucket-name>

</details>
