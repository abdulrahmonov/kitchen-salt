# kitchen-salt installation
Hello and Welcome!!!

To install kitchen-salt please follow the steps below and create your own kitchen-salt environment. Let’s go!!!

This is our directory structure:
```
+——-  kitchen-salt
|          |   kitchen.yml
|          |   Gemfile
|          \  -— srv
|                 |
|                 +--- pillar
|                 |         |  --- pillars.sls
|                 + --- salt
|                     \ —-  prometheus_agent_deploy
|                      |    |  — inis.sls
|                      |    |  — windows_exporter-0.16.0-amd64.msi
|                     \ --- clamav
|                           | —- init.sls
|                           | —- clamav-0.104.2.win.x64.msi
```

Step 1.
Download and install ruby: https://rubyinstaller.org/downloads/ 

Step 2.
Install Chef Workstation: https://www.chef.io/downloads/tools/workstation

Step 3.
Bundler provides a consistent environment for Ruby projects by tracking and installing the exact gems and versions that are needed.
Run  `gem install bundler` command.

Step 4.

NOTE: If you are cloning this repo, you will have Gemfile, kitchen.yml and srv/states_directories  are already created. 

Manually creating.
Specify your dependencies in a Gemfile in your project's root: 
Create a Gemfile :
```
source 'https://rubygems.org'
gem 'test-kitchen'
gem ‘kitchen-inspec’
gem 'kitchen-salt'
gem 'kitchen-azurerm'
gem 'kitchen-sync'
gem 'git'
```
Run `$ bundle install`
Don’t forget to create srv/pillar/pillars.sls:
```
top.sls:
  base:
    "*":
      - clamav
      - prometheus_agent_deploy

```
Also srv/salt/top.sls:
```
base:
  "*":
    - clamav
    - prometheus_agent_deploy

```
Now we are creating clamav and prometheus_agent_deploy directories with state files next to the top.sls file.  NOTE: kitchen-salt/srv/salt/ will be the location to create your sls files.  

Step 5.
Source: [GitHub - test-kitchen/kitchen-azurerm: A driver for Test Kitchen that works with Azure Resource Manager](https://github.com/test-kitchen/kitchen-azurerm)

*On Mac*: Install azure cli :
 `$ brew update && brew install azure-cli`
*On Windows* follow the steps on this link to install azure cli :https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli

Step 6.
`az ad sp create-for-rbac` (creates Azure service principal)

When creating a service principal, you choose the type of sign-in authentication it uses. There are two types of authentication available for Azure service principals: password-based authentication, and certificate-based authentication.
Password-based authentication:

```
az ad sp create-for-rbac --name ServicePrincipalName --role Contributor
```

Step 7.
`az login ` using your target subscription ID. You will also need to ensure you have an active Azure subscription.

NOTE: Don't forget to save the values from the output -- most importantly the password

Using a text editor, open or create the file `~/.azure/credentials` and add the following section, noting there is one section per Subscription ID. Make sure you save the file with UTF-8 encoding

```
[ADD-YOUR-AZURE-SUBSCRIPTION-ID-HERE-IN-SQUARE-BRACKET]
client_id = "your-azure-client-id-here"
client_secret = "your-client-secret-here"
tenant_id = "your-azure-tenant-id-here"
```

Step 8.
After adjusting your `~/.azure/credentials` file you will need to adjust your `kitchen.yml `file to leverage the azurerm driver. 
Create file kitchen.yml:
```
---
#The driver is what deploys our infrastructure out. 
#It can be a hypervisor, cloud provider, abstraction layer to the hypervisor.
driver:
  name: azurerm
  #This is Global Configuration option. It sets the driver to azurerm and then sets the all platforms inside 
  #the kitchen.yml to use its configuration.
  some_config: true 
  #Using username and password will be needed if you decide to connect and troublshoot the VM.
  username: admin
  password: UseStrongP@ssword2022
driver_config:
  #Your azure acoount subscribtion id is needed.
  subscription_id: 'your-azure-subscribtion-id-here'
  location: 'Central US'
  machine_size: 'Standard_DS2_v2'

provisioner:
  name: salt_solo
  #salt_install ensures we’re using the bootstrap script to install.
  salt_install: bootstrap
  salt_version: latest
  log_level: info
  sudo: true
  #Treats the root directory of this project as a complete file root. 
  is_file_root: true
  #local_salt_root will require that a salt directory be located at srv/salt/ with all the state files in it.
  local_salt_root: './srv'
  #Below command will require top.sls file to be located with states directory under the srv/salt/
  state_top_from_file: true
  require_chef: false
  #List of filenames and directories to be excluded when copying to the test servers.
  salt_copy_filter:
    - __pycache__
    - '*.pyc'
    - .tox
    - .nox
    - artifacts
    - .bundle
    - .git
    - .gitignore
    - .kitchen
    - kitchen.yml
    - Gemfile
    - Gemfile.lock
    - README.rst
platforms:
  - name: windows-2019
    driver_config:
      #Image URN is used for vm creation.
      image_urn: MicrosoftWindowsServer:WindowsServer:2019-Datacenter-smalldisk:latest
    #transport - specifies which transport to use when executing commands remotely on the test instance. 
    #winrm is the default transport on Windows. The ssh transport is the default on all other operating systems.
    transport:
      name: winrm
      elevated: true
#suite is a combination of the platforms you provide and a software suite to test on.
suites:
  - name: default
    attributes:
```

Step 9.
Now time to test. Run `kitchen converge`  This command will create windows-2019 VM and test our clamav and prometheus_agent_deploy states in our azure account subscription.  When you run any kitchen command .kitchen directory automatically will be created and it will have all the logs for you convenience.  You can also run following 
```
Commands:
  kitchen console                                 # Test Kitchen Console!
  kitchen converge [INSTANCE|REGEXP|all]          # Change instance state to converge. Use a provisioner to configure one or more instances
  kitchen create [INSTANCE|REGEXP|all]            # Change instance state to create. Start one or more instances
  kitchen destroy [INSTANCE|REGEXP|all]           # Change instance state to destroy. Delete all information for one or more instances
  kitchen diagnose [INSTANCE|REGEXP|all]          # Show computed diagnostic configuration
  kitchen doctor INSTANCE|REGEXP                  # Check for common system problems
  kitchen exec INSTANCE|REGEXP -c REMOTE_COMMAND  # Execute command on one or more instance
  kitchen help [COMMAND]                          # Describe available commands or one specific command
  kitchen init                                    # Adds some configuration to your cookbook so Kitchen can rock
  kitchen list [INSTANCE|REGEXP|all]              # Lists one or more instances
  kitchen login INSTANCE|REGEXP                   # Log in to one instance
  kitchen package INSTANCE|REGEXP                 # package an instance
  kitchen setup [INSTANCE|REGEXP|all]             # Change instance state to setup. Prepare to run automated tests. Install busser and rela...
  kitchen test [INSTANCE|REGEXP|all]              # Test (destroy, create, converge, setup, verify and destroy) one or more instances
  kitchen verify [INSTANCE|REGEXP|all]            # Change instance state to verify. Run automated tests on one or more instances
  kitchen version                                 # Print Test Kitchen's version information
```


You are all set. By the way don’t forget to run `kitchen destroy`  to delete  and check your environment. 
NOTE: If your tests succeeded,  `kitchen test` will only destroy the VM, but your vnet, public, and other resources won’t be deleted. 


