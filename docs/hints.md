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
    You found a GKE (Google Kubernetes Engine) cluster.<br>
    As you are not authenticated, you are part of the group `system:anonymous` and you can't access much.<br>
    What if you were in `system:authenticated`?<br>
</details>
<br>

<details>
  <summary>Hint 2</summary>
    `system:authenticated` sounds like strict access control - but is it?<br>
    All you need to do is authenticate - with pretty much any Google account.<br>
    What if you can get a token for your own Google account and provide that to the API?<br>
    Are there any endpoints you can access now?<br>
</details>
<br>

<details>
  <summary>Hint 3</summary>
    `system:authenticated` will require you to present a Google access token.<br>
    It can be any token - also for your own Google account that is not associated with our target GCP project.<br>
    You can use the [oauth playground](https://developers.google.com/oauthplayground/) to get an access token.<br>
    Select "Kubernetes Engine API v1" as a scope and exchange your authorization code for an access token.<br>
    To simplify the following commands, set your token in an environment variable: `export TOKEN=<your token>`<br>
    Present it to the GKE API:<br>
    `curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api`<br>
    That's a more promising response than `403 Forbidden1`!<br>
    Maybe you can find out, which permissions you have on the cluster as part of the `system:authenticated` group.<br>
</details>
<br>

<details>
  <summary>Hint 4</summary>
    It would be nice to know what you can access on the cluster.<br>
    Luckily, there is an endpoint for that too and you are allowed to query it:<br>
    `curl -k -X POST -H "Content-Type: application/json" -d '{"apiVersion":"authorization.k8s.io/v1", "kind":"SelfSubjectRulesReview", "spec":{"namespace":"default"}}' -H "Authorization:Bearer $TOKEN" https://$IP/apis/authorization.k8s.io/v1/selfsubjectrulesreviews`<br>
    It looks like you have read access to some resources on the default namespace of the cluster. Start enumerating some that might be interesting.<br>
</details>
<br>

<details>
  <summary>Hint 5</summary>
    You can read all resources in the `file-uploader` namespace on the cluster. Which secrets might it hold?<br>
    `curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api/v1/namespaces/default/secrets`<br>
</details>
<br>

Useful commands and tools:

- `nmap -sC -sV <IP>` (don't worry if you don't have nmap installed. Guessing common open ports also works here)
- `curl -k https://<IP>`
- `curl -k -H "Authorization:Bearer <token>" https://<IP>/api/v1/...`
- https://developers.google.com/oauthplayground/

### Challenge 2: State of affairs
### Challenge 3: Computing power
### Challenge 4: Invoking answers
### Challenge 5: In the shoes of an admin



