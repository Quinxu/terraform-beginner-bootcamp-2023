# Terraform Beginner Bootcamp 2023

## Semantic Versioning

This project is going to utilize semantic versioning for its tagging. [semver.org](https://semver.org/)

The general format is in **MAJOR.MINOR.PATCH**:

- **MAJOR** version when you make incompatible API changes
- **MINOR** version when you add functionality in a backward compatible manner
- **PATCH** version when you make backward compatible bug fixes

For example, `1.0.1`

## Install the Terraform CLI
### Find Linux distribution
```
gitpod /workspace/terraform-beginner-bootcamp-2023 (2-refactor-terraform-cli) $ cat /etc/*-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=22.04
DISTRIB_CODENAME=jammy
DISTRIB_DESCRIPTION="Ubuntu 22.04.3 LTS"
```
### Located the Installation commands 
Located the commands based on Linux distribution from the following documentation
[Install Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Put the Commands in the Bash Script
Put the commands in /bin/install_terraform_cli bash script file and used it in gitpod.yml.

### Changed the Bash File Permission

### Run the Bash File in gitpod.yml


### Updated The Task Execution Order in gitpod.yml
Changed from init to before to deal with the case of a workspace restart.
https://www.gitpod.io/docs/configure/workspaces/tasks


### Work with Env Vars

#### env command
To list all env vars, 'env'

To filter it by xxx, 'env | grep xxx'

#### setting and unsetting Env Vars
To set an env var, `export varname=xxx`

To unset an env var, `unset varname`

To set env var inline when running a command
```
varname=xxx, ./bin/script
```

To set env var in a script
```
varname=xxx
echo $varname
```

#### Scope of Env Vars
It only exists in the created terminal. 

If it needs to be accessed across all terminals, it needs to be created in the bash profile - .bash_profile

#### Persist Env Vars in Gitpod
```
gp env varname=xxx
```
All future workspaces launched will have the set env var for all terminals opened in those workspaces.

You can also set env vars for unsensitive value in ./gitpod.yml.

Set sensitive env var in .env file, and put the file in gitignore to keep the values locally.

### AWS CLI Installation

The bash script (./bin/install_aws_cli) is created to install AWS CLI for this project based on the [Install or update the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

We can check if our AWS credentials is configured correctly by running the following AWS CLI command:
```
aws sts get-caller-identity
```

Set env vars based on [Env var to configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)

If the env var are set correctly according to AWS IAM Users' setting, the command should return the following json code:
```json
{
    "UserId": "AIDAUAHNXGL7GECYBBCXX",
    "Account": "278376000000",
    "Arn": "arn:aws:iam::278376000000:user/terraform-beginner"
}
``` 

## Terraform Basics
For more information, please refer to [Terraform Registry](https://registry.terraform.io/)

### Terraform
It uses Infrastructure as Code to provision and manage any cloud, infrastructure, or service such as physical machines, VMs, network switches, containers, and more.

### Terraform Registry
It makes easy to use any provider or module. To use a provider or module from The Terraform Registry, just add it to your configuration; when you run `terraform init`, Terraform will automatically download everything it needs.

### Terraform Providers
They are the plugins that Terraform uses to manage those resources. Every supported service or infrastructure platform has a provider that defines which resources are available and performs API calls to manage those resources.

### Terraform Modules
They are reusable Terraform configurations that can be called and configured by other configurations. Most modules manage a few closely related resources from a single provider.

### Terraform Main Commands
  - init      
    Prepare your working directory for other commands
  - validate  
    Check whether the configuration is valid
  - plan      
    Show changes required by the current configuration
  - apply     
    Create or update infrastructure.
    - `terraform apply --auto-approve`
  - destroy   
    Destroy previously-created infrastructure

To see more commands, run `terraform`

### Terraform Lock Files
 Currently, the Terraform only remembers the Terraform Provider dependency version chosen within the configuration lock file `.terraform.lock.hcl`

 It is recommended that the lock file be included in version control repositories with the rest of the Terraform (.tf) files for the project.

 When `terraform init` command is run, it will automatically create the Terraform Lock File if it doesn’t exist. If the file already exists, then Terraform will update it with the latest dependency versions selected.

 If need to force the selected dependency versions to be updated, the -upgrade attribute flag can be added to the terraform init command, `terraform init -upgrade`



### Terraform State Files
`Terraform.tfstate` is a file that Terraform uses to track the state of the infrastructure it manages. The state file contains information about the resources that Terraform has created or is managing, such as the resource type, attributes, and relationships. Terraform uses the state file to determine which changes to make to your infrastructure when you run terraform apply.

One should not edit the terraform.tfstate file directly, as this can cause Terraform to become confused about the state of your infrastructure. If you need to modify the state file, you can use the terraform state command.

The `terraform.tfstate.backup` file is a backup of the terraform.tfstate file. Terraform automatically creates a backup of the state file before making any changes to the state file. This ensures that you can recover from a corrupted or lost state file.

The terraform.tfstate.backup file is stored in the same directory as the terraform.tfstate file. It is overwritten every time Terraform makes changes to the state file.

You can use the terraform.tfstate.backup file to restore your Terraform state to a previous version. To do this, simply rename the terraform.tfstate.backup file to terraform.tfstate and run terraform init.

The both files shouldn't be committed to VCS.

### Terraform Directory
Terraform uses configuration content from `.terraform`, and also uses the directory to store settings, cached plugins and modules, and sometimes state data.

## Terraform Cloud
- After signing in the registered account at [terraform.io](https://app.terraform.io/session), select to create the blank workspace of a organziation.
- Create the new project - terraform-beginner-bootcamp-2023
- When attempted to run `terraform login` from terminal, it didn't open browser properly to generate a token. The workaround is manually generate a token in [Terraform cloud](https://app.terraform.io/app/settings/tokens?source=terraform-login), copied the token string into /home/gitpod/.terraform.d/credentials.tfrc.json 
```
{
    "credentials": {
      "app.terraform.io": {
        "token": "xxxxx"
      }
    }
}
```