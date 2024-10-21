[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# gcp-ctf-workshop

> [!WARNING]
> This CTF setup will create a misconfigured GCP project that is vulnerable to the internet.
> Don't spin this up in a production environment.

This repository contains the code used to set up the infrastructure for our BSides NY 2024 workshop "A hitchhiker's guide to a Google Cloud CTF"

You can use this setup if you want to experiment with the challenges in your own GCP project.

The information that participants will need and hints for each challenge are in this repository and also in the presentation marked: `BSidesNYC2024.pdf`


## Setting up the challenge

The `challenge-setup.sh` script takes care of the setup.
It uses terraform to create the cloud resources.
It also sets up further configurations such as uploading files and configuring resources.
It generates some credential files used in the challenge such as ssh keys or service account keys. These files are added to the .gitignore file so that they don't get checked in.

To successfully run the script, you need the following prerequisites:
- a google cloud account, and the `Owner` role on a google cloud project, so you will have all permissions needed to create the challenge resources
- terraform
- gcloud and gsutil
- kubectl (can also be installed as a gcloud component with `gcloud components install kubectl`)

To set up the challenge run the `./challenge-setup.sh` script. Creating the terraform resources, especially the GKE cluster, will take a few minutes.

## Cleaning up

To remove the resources created in your cloud project run the `challenge-destroy.sh` script.
It runs terraform destroy, and it cleans up the credential files we created. 
