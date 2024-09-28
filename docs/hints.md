# CTF Guide

## Your Goal

Your goal of this CTF is to exploit a vulnerable GCP project and find up to 5 flags.
During the challenge you will be able to move through the environment and step by step escalate your privileges until you manage the IAM bindings on the project, esentially allowing you to gain control of all resources in the project.
(In our CTF workshop setup, we have to keep you in check a bit and you will only be able to manage specific IAM bindings.)

## Prerequisites

To play this CTF and participate in our workshop you will need:
- A notebook and an internet connection
- A Google account. Any Google account such as `your-throwaway@gmail.com ` is enough. It does not have to be a Google Cloud account. 
- The [gcloud](https://cloud.google.com/sdk/docs/install) command line utility installed on your computer.
- The kubectl utility installed on your computer. You can install it as a component of gcloud: `gcloud components install kubectl`

## Your starting point

The cloud services in the project might be misconfigured or leak information that can be useful for you as attacker.
You'll start out with just an IP address as your first piece of information.

We are providing you with useful hints and commands for each challenge.
Don't hesitate to use them, as you will have limited time for this CTF during our workshop.

## Challenges

### Challenge 1: Cluster confidentials

You received just an IP address as your very first entrypoint into the GCP project.  
Which ports are open? Is something listening here?  
Does it give you an idea what kind of infrastructure it is?

To simplify your next commands, set the IP address as an environment variable: `export IP=<IP>`

<details>
  <summary>Hint 1</summary>

    You found a GKE (Google Kubernetes Engine) cluster.  
    As you are not authenticated, you are part of the group `system:anonymous` and you can't access much.  
    What if you were in `system:authenticated`?  

</details>
  

<details>
  <summary>Hint 2</summary>
    
    `system:authenticated` sounds like strict access control - but is it?  
    All you need to do is authenticate - with pretty much any Google account.  
    What if you can get a token for your own Google account and provide that to the API?  
    Are there any endpoints you can access now?  
    
</details>
  

<details>
  <summary>Hint 3</summary>

    `system:authenticated` will require you to present a Google access token.  
    It can be any token - also for your own Google account that is not associated with our target GCP project.  
    You can use the [oauth playground](https://developers.google.com/oauthplayground/) to get an access token.  
    Select "Kubernetes Engine API v1" as a scope and exchange your authorization code for an access token.  
    To simplify the following commands, set your token in an environment variable: `export TOKEN=<your token>`  
    Present it to the GKE API:  
    `curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api`  
    That's a more promising response than `403 Forbidden1`!  
    Maybe you can find out, which permissions you have on the cluster as part of the `system:authenticated` group.  

</details>
  

<details>
  <summary>Hint 4</summary>

    It would be nice to know what you can access on the cluster.  
    Luckily, there is an endpoint for that too and you are allowed to query it:  
    `curl -k -X POST -H "Content-Type: application/json" -d '{"apiVersion":"authorization.k8s.io/v1", "kind":"SelfSubjectRulesReview", "spec":{"namespace":"default"}}' -H "Authorization:Bearer $TOKEN" https://$IP/apis/authorization.k8s.io/v1/selfsubjectrulesreviews`  
    It looks like you have read access to some resources on the default namespace of the cluster. Start enumerating some that might be interesting.  

</details>
  

<details>
  <summary>Hint 5</summary>

    You can read all resources in the `file-uploader` namespace on the cluster. Which secrets might it hold?  
    `curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api/v1/namespaces/default/secrets`  
    The secret values are base64 encoded. Decode them to read the value:  
    `echo -n <secret-value> | base64 -d  

</details>
  

Useful commands and tools:

- `nmap -sC -sV <IP>` (don't worry if you don't have nmap installed. Guessing common open ports also works here)
- `curl -k https://<IP>`
- `curl -k -H "Authorization:Bearer <token>" https://<IP>/api/v1/...`
- [Google OAuth Playground](https://developers.google.com/oauthplayground/)

### Challenge 2: State of affairs

You found credentials for a GCP service account.
The json blob already provides some useful information. It contains the GCP project ID, the e-mail of the service account (client_e-mail) and the private key of the account.  

Save the json blob in a file. You can now also use it as a credential for the gcloud CLI:  
`gcloud auth activate-service-account --key-file <path-to-file>`  
You can check that this worked when running `gcloud auth list`. It now shows the service account as active account.  

So what can you do with this account? Did you find any hints during challenge 1?

<details>
  <summary>Hint 1</summary>

    In the configmap and deployment of the app ond the GKE cluster, you can find the name of a storage bucket.  
    Probably the service account you found belongs to this app and it can access the storage bucket.  

</details>

<details>
  <summary>Hint 2</summary>

    The file uploader app running on the GKE cluster can access a storage bucket called "file-uploads-<gcp-project-id>.  
    While the service account can't list all storage buckets, it might still have access to this specific bucket.  

</details>

<details>
  <summary>Hint 3</summary>

    See what you can find on the bucket by using the `gsutil` command line utility.  
    `gsutil ls gs://<bucket-name>`
    While the service account can't list all storage buckets, it might still have access to this specific bucket.  

</details>

Useful commands and tools:

- gsutil (already installed with gcloud): gsutil ls gs://<...>

### Challenge 3: Computing power

The file on the storage bucket is pretty useful for you as attacker.  
That seems to be the leftovers of a terraform pipeline that someone set up for this GCP project.  
They deployed parts of the infrastructure with terraform and you can trace back what the developers did in the terraform state file.

Would that help you to move on into other infrastructure deployed here?

<details>
  <summary>Hint 1</summary>

    The state file contains the parameters that were used to setup a Google Compute Engine VM.  
    But additionally, it contains a secret ...  
    Can you combine this information to access the VM?

</details>

<details>
  <summary>Hint 2</summary>

    The state file contains the parameters that were used to setup a Google Compute Engine VM.  
    But additionally, it contains a secret ...  
    Can you combine this information to access the VM?

</details>

<details>
  <summary>Hint 3</summary>

    The state file conveniently contains the external IP address of a compute engine that was deployed with terraform.  
    But someone also created a Google Secret Manager secret with terraform and specified the secret value as well.  
    If you do that, you have to protect your state file as well, as it will contain the secret value in plain text.  
    Use the SSH key you find in the secret to SSH into the VM.  

</details>


### Challenge 4: Invoking answers
### Challenge 5: In the shoes of an admin



