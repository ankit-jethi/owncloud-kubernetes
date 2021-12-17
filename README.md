# Owncloud on Kubernetes
Deployed on AWS using Terraform and Ansible

>A domain is required.

<p align="center">
  <img src="architecture_diagram.png" alt="Architecture Diagram">
</p>

## How to setup:

>Installation steps for Ubuntu 18.04 LTS.

- Install python.
- Install terraform (Tested with v1.0.7).

```
curl "https://releases.hashicorp.com/terraform/1.0.7/terraform_1.0.7_linux_amd64.zip" -o "terraform_1.0.7_linux_amd64.zip"

unzip terraform_1.0.7_linux_amd64.zip

sudo mv terraform /usr/local/bin/
```

- Create an IAM user with programmatic access and attach the AdministratorAccess policy. (Note down the Access key ID & Secret access key)
- Install AWS CLI.

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install

# The following command will ask you for your Access key ID & Secret access key:
aws configure
```

- Install ansible (Tested with v2.9.24).

```
sudo apt update

sudo apt install software-properties-common

sudo add-apt-repository --yes --update ppa:ansible/ansible

sudo apt install ansible=2.9.24-1ppa~bionic
```

- Generate an ssh-key and give it to the ssh-agent.

```
ssh-keygen -t rsa -b 4096

eval `ssh-agent`

ssh-add /path/to/the/private/key

# To confirm:
ssh-add -l
```

- Create a reusable Route 53 delegation set. (Note down the delegation set id & the name servers)

```
aws route53 create-reusable-delegation-set --caller-reference <enter-unique-string> 
```

```
# Example output:

{
    "Location": "https://route53.amazonaws.com/2013-04-01/delegationset/ABCD1234EFGH5678",
    "DelegationSet": {
        "Id": "/delegationset/ABCD1234EFGH5678",
        "CallerReference": "<unique-string>",
        "NameServers": [
            "ns-123.awsdns-45.com",
            "ns-678.awsdns-90.net",
            "ns-2814.awsdns-39.co.uk",
            "ns-1246.awsdns-75.org"
        ]
    }
}
```

- Put the name servers in the settings of your Domain Name provider.
- Now, clone this repository.
```
git clone https://github.com/ankit-jethi/owncloud-kubernetes.git

cd owncloud-kubernetes/
```
- For terraform variables: Refer to [variables.tf](../master/terraform/variables.tf) and [example.tfvars](../master/terraform/example.tfvars) and create **terraform.tfvars** in the terraform directory.
- Create an S3 bucket to store **terraform state**. And put the S3 bucket details in [backend.conf](../master/terraform/backend.conf).
- For ansible variables: Edit [all.yml](../master/group_vars/all.yml) in group_vars directory (Some variables are managed by terraform).
>For SSL/TLS certificates, by default, staging environment (test certificate) is selected for **Let's Encrypt**. This is recommended to avoid hitting rate limits. Once deployed and verified, you can switch to the production environment by following the steps mentioned in the [Switching to production environment of Let's Encrypt section](#switching-to-production-environment-of-lets-encrypt).

Now run these commands:  
- To install required ansible collections and roles.
```
ansible-galaxy install -r requirements.yml
```
- To initialize terraform backend and providers.
```
cd terraform/

terraform init -backend-config=backend.conf
```  
- To create an execution plan.
```
terraform plan -out=plan.out
```  
- To execute the plan and create the infrastructure.
```
terraform apply plan.out
```

Now, wait for 20-30 minutes for the whole infrastructure to be set up.

Then access Owncloud at https://your-domain.com and Kibana at https://kibana.your-domain.com

## Switching to production environment of Let's Encrypt:

>Run these commands only after deploying and verifying using staging environment.

- Edit [all.yml](../master/group_vars/all.yml) in group_vars directory:
```
# Change the values of these variables as mentioned below:

kibana_test_certificate: false
kibana_certificate_force_renewal: true

owncloud_test_certificate: false
owncloud_certificate_force_renewal: true
```
- Now run this command from the same directory as [site.yml](../master/site.yml):
```
ansible-playbook --inventory aws_inventory --skip-tags "always" --tags "kibana-ssl-setup,owncloud-ssl-setup" --verbose site.yml
```

## Cleaning up:

- To delete the infrastructure:
```
cd terraform/

terraform destroy
```
- Delete the S3 bucket containing the terraform state.
- Delete the ACM certificate for owncloud application.

## Info:

- [Owncloud kubernetes files:](../master/roles/owncloud/templates/)

[01-namespace.yml:](../master/roles/owncloud/templates/01-namespace.yml)  
It creates a namespace for the owncloud application.

[02-persistent-volume.yml:](../master/roles/owncloud/templates/02-persistent-volume.yml)  
It creates an NFS-backed persistent volume using **Elastic File System (EFS)**.

[03-persistent-volume-claim.yml:](../master/roles/owncloud/templates/03-persistent-volume-claim.yml)  
It creates a persistent volume claim for use with the owncloud pods.

[04-config-map.yml:](../master/roles/owncloud/templates/04-config-map.yml)  
It creates a config map to provide values to owncloud environment variables.

[05-secret.yml:](../master/roles/owncloud/templates/05-secret.yml)  
It creates a secret to provide values to sensitive owncloud variables like database username, password and so on.

[06-deployment.yml:](../master/roles/owncloud/templates/06-deployment.yml)  
a. It creates a deployment with 2 pods.  
b. For updates, rolling update strategy is used.  
c. A **readiness probe** is set up for health checks.  
d. For database, MariaDB is set up on **Relational Database Service (RDS)**.

[07-service.yml:](../master/roles/owncloud/templates/07-service.yml)  
It creates a NodePort service.

- [certbot_acm.py.j2](../master/roles/k8s-master/templates/certbot_acm.py.j2) (python script):

It uses **Certbot** to get SSL/TLS certificates for owncloud application from Let’s Encrypt and then uploads it to **AWS Certificate Manager (ACM)**. To renew the certificate, a cron job is set up which executes this script twice a month.

- Elastic Stack and Nginx:

It is used for **log management** and **infrastructure monitoring**.

The following components are created:  
a. [Filebeat](../master/roles/filebeat/templates/filebeat.yml.j2) - To get the system and kubernetes logs.  
b. [Metricbeat](../master/roles/metricbeat/templates/metricbeat.yml.j2) - To get the system metrics (CPU, memory, disk & network usage) and kubernetes metrics (available & unavaible pods, etc).  
c. [Heartbeat](../master/roles/heartbeat/templates/heartbeat.yml.j2) - It is used for uptime monitoring of owncloud application.  
d. Nginx - It is used as reverse proxy, caching server and for SSL termination.

