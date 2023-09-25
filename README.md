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