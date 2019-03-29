Compucorp Infrastructure Exercise
https://compucorp.neilborromeo.com



System Overview
System Context
Main Processes
Components
Infrastructure
Infrastructure Resources/Diagram
EC2 Instances List:
AWS Diagram
Provisioning
Packer
Terraform
Environments
Credentials
First time execution
Ansible
Agent less:
Idempotent:
Ansible Users role
First time execution
Deployment Tier
Technical Debts
Monitoring
Cron Jobs
Server Management (manual)
System Overview
System Context


Compucorp CRM is a whole system created that essentially:
collects data from customers or potential customers and other external sources.
in order to process all customer relations through several steps, and in several ways;
with the purpose of providing individual or aggregated data, for instance tables and charts;
that can be visualized through a Web UI
Main Processes
The whole system can also be described briefly by the following main processes: (these list are made up)
Data Collection
Data Visualization
Background Processing
Complementary Processing
Components
The diagram below should provide you a summarized view of the whole system:

CRM: can be access at https://compucorp.neilborromeo.com

Infrastructure
Infrastructure Resources/Diagram
EC2 Instances List:
Instance name
Instance
Type
Roles
OS Type
Comments
STG_CRM_web_1
t1.micro
Back Process Administration & Web
Linux Ubuntu 16.04
Used also as file storage

AWS Diagram

Provisioning
We can re-create all the AWS resources and populate initial data sets using Packer, Terraform and Ansible. The full infrastructure code is at on github.
Packer
Packer is easy to use and automates the creation of any type of machine image. It embraces modern configuration management by encouraging you to use automated scripts to install and configure the software within your Packer-made images. Packer brings machine images into the modern age, unlocking untapped potential and opening new opportunities.
Using packer allows to have a unique AMI on AWS to work on, mitigating possible failures caused using different AMIs, this custom AMIs can be provisioned with base ansible tasks ensuring that the AMI used by the EC2 instances will be the same no matter the region (stock AMIs could not be available in some regions) removing possible failures when provisioning.
Packer configuration is part of the infra repository on github.
The way Packer works is it will create a temporal EC2 instance (packer is able to use several builders) using a base AMI after that it will provision that instance with the ansible compucorp-playbook-packer-base.yml that will run the base and users roles, then it will create the new AMI and stored in the configured regions, at the end packer returns the AMIs IDs.
Compucorp Custom AMI
In order to have a unique AMI in different regions, we created the COMPUCORP_DEMO_AMI using as base ami-0a386db7264bbbca5 an amazon community AMI based in Ubuntu 16.04 and we distributed this AMI on us-east-1 region.
Note: We can create a copy of COMPUCORP_DEMO_AMI manually to a different region using the AWS Console

Terraform
Infrastructure as Code: Infrastructure is described using a high-level configuration syntax. This allows a blueprint of your datacenter to be versioned and treated as you would any other code. Additionally, infrastructure can be shared and re-used.
Execution Plans: Terraform has a "planning" step where it generates an execution plan. The execution plan shows what Terraform will do when you call apply. This lets you avoid any surprises when Terraform manipulates infrastructure.
Resource Graph: Terraform builds a graph of all your resources, and parallelism the creation and modification of any non-dependent resources. Because of this, Terraform builds infrastructure as efficiently as possible, and operators get insight into dependencies in their infrastructure.
Change Automation: Complex changesets can be applied to your infrastructure with minimal human interaction. With the previously mentioned execution plan and resource graph, you know exactly what Terraform will change and in what order, avoiding many possible human errors.
Environments
One environment will be provisioned - STG (by the end of the Infra Plan)
This environments Terraform infrastructure definition files can be found on the compucorp-infrastructure repository. 
 
 
 
 
This is master's branch directory tree:
├── ansible
│   ├── inventory
│   ├── playbooks
│   ├── roles
│   └── vars
├── packer
└── terraform
        ├── qa
        └── staging
packer contains the packer files to create the custom AMI. Take a look at Provisioning with Packer section above.
terraform contains the actual infrastructure files, and there you will find a staging folder. This is where the infrastructure definition files reside to provision all AWS resources.
Credentials
There are several ways to let Terraform know your AWS account credentials, but the one we have adopted is the Credentials File.
You should create the /etc/.aws/credentials file (or whatever you like, as long as you modify the values mentioned below) with the following content:
/etc/.aws/credentials
[compucorp-stg]
aws_access_key_id = xxxxxxxxx
aws_secret_access_key = yyyyyyyyyyyyyyyyy 
region=us-east-1
Where compucorp-{env} is the profile name you will use on Terraform files to reference your credentials.
You can check this file inside your environment directory (e.g.: terraform/staging/):
config_provider.tf
provider "aws" {
    region = "${var.region}"
    shared_credentials_file = "/etc/.aws/credentials"
    profile = "compucorp-stg"
}
First time execution
If this is the first time you will execute the Terraform recipes (that is, no infra exists on the configured AWS account / region) , these are the steps to follow:
Clone compucorp-infrastructure repository
Take a look on the config files in case you need to change something (specially config_provider.tf).
Create and populate the "secrets" file if we need this for initial password we use for provisioning.
We could also use AWS Certificates as it’s more convenient and it’s free.
Now you should be ready to execute Terraform and let it do it's magic:
terraform plan
terraform apply

Ansible
Agent less:
Ansible is agentless which frees you from installing agents on servers and managing them unlike the other configuration management tools like Chef, Puppet. This agentless architecture has added several advantages for Ansible in terms of  network security by communicating through SSH, zero bootstrapping and resource utilization. So SSH and key pairs are your friends when using Ansible.
Idempotent:
Ansible uses what are known as “playbooks” which define what actions need to be performed on the instances. Ansible playbooks are idempotent, which means you can run your playbooks as many times and the state will not be affected unless you define a change. So playing with your playbooks will not break your system.

and more.


Ansible Users role
This role has two responsibilities:
Add or remove configured users
Enable or disable users to login as root
All user information is stored in the vars file of the role
File: ansible/roles/users/vars/main.yml
users:
  nborromeo:
    name: Neil Borromeo
    groups: ['nborromeo','devops','devs','apps','www-data']
    uid: 1201
    ssh_key: "ssh-rsa AAAAB3N..."
The users are configured by environment, using two dictionaries:
File: ansible/vars/{env}/vars.yml where {env} could be QA|DEV|STG
users_state
users_enabled_as_root
users_state:
  appadmin: present
  nborromeo: present

users_enabled_as_root:
  appadmin: present
  nborromeo: present
To enable a user use the present state
To disable a user use the absent state.
 
First time execution
In order to provision all the instances for the first time some manual steps are needed to connect.
The ssh key that was used to create the instances from terraform
Refresh the dynamic inventory
Special ssh configuration to connect using the available initial ssh users
All commands should be executed within the ansible directory
Refresh ansible dynamic inventory cache
We use the ec2 public DNS name to connect to the instances for this setup.
inventory/ec2.py --refresh-cache
If you have multiple aws keys configured under ~/.aws/credentials, you can include --boto-profile=yourprofilehere in the parameter or just --profile argument. This will return a list of resources in json format of your AWS account based on your AWS key permissions/policy attached.
SSH configuration
To connect the first time to the target host an explicit ssh entry is needed with the full public dns name and the AMI available user (ubuntu). Make sure to replace terraform_id_rsa with the key we used when we deployed the instances through Terraform.
Host STG_CRM_web_1
 Hostname 18.212.210.66
 IdentityFile ~/.ssh/compucorp
 IdentitiesOnly yes
 User ubuntu
Ansible execution
AWS_PROFILE=compucorp-stg ansible-playbook -e@vars/STG/vars.yml playbooks/compucorp-crm.yml
This is a special playbook that runs all the task to provision the complete environment
Note: We could also do this in many different ways like using a bastion host. We could also make use of vault variables within our playbooks to securely define passwords / credentials.
Deployment Tier
We can use CI/CD services like Atlassian Bamboo for building and deploying our apps across these instances. It will also be used during releases and doing some re-curring tasks if there are any. A quick idea is that, all developers will commit their code changes to the repository, and do a merge/request. It’s not part of this demo yet.
Technical Debts
Create an ansible role to populate initial databases under “sql” folder in the project repository
Create a role to install certbot and configure for the domain
Create deployment workflow
Create an ansible role to install the cronjob scheduler
Create an ansible role to install drush

Monitoring
No monitoring included in this project yet. Most of the implementation that helps us monitor our apps could be using Consul.IO, RollBar, and some simple ones like UptimeRobot, SolarWinds, Nagios, internal AWS Cloudwatch, NewRelic. and more.
Cron Jobs
# Daily backups
0 1 * * * /bin/bash $HOME/.scripts/backup.sh

# Weekly backups
0 2 * * 7 /bin/bash $HOME/.scripts/backup.sh

# Monthly backups
0 3 1 * * /bin/bash $HOME/.scripts/backup.sh

# Clean-up old files older than 3 months
0 1 * * * /usr/bin/find $HOME/backups/* -type f -mtime "+$(( ( $(date '+%s') - $(date -d '3 months ago' '+%s') ) / 86400 ))" -delete

Server Management (manual)
We can connect to the server via SSH. As mentioned in a couple of sections above, we can connect to the server via SSH. First we need to en-list our IP address to be able to connect to the security group as we use it as our main firewall for this exercise. You may ask Neil to set this up for you or we can arrange a time to open the SSH port to everyone in the security groups settings in AWS console.

Normally, we use bastion host to manage AWS resources across our instances. We then encapsulate all resources inside a private VPC and with Elastic Load balancers in place.
