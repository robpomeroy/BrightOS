# Installation

## Prerequisites

You will need a machine from which to run Ansible. In addition, your target machine should meet the following requirements:

* Ubuntu installed (preferably minimal, for the cleanest effects; I use Ubuntu Server)
* OpenSSH installed
* A user account set up, with a password and sudo capability
* Public/private keys set up for this user (TODO: document this)
* The latest version of Python installed

## Setup and run

In brief (TODO: expand):

1. Edit ```config.yml``` to suit your preferences (see annotations in that file)
2. Enter your target machine's DNS name or IP address into ```inventory```
3. On your Ansible control machine, run ```ansible-galaxy install -r requirements.yml``` to pull down the required external roles
4. Run ```ansible-playbook main.yml -i inventory --ask-become-pass```

Note: for advanced use (e.g. during further development of the playbook), you can use ```[--skip-tags "tag1"] [--tags "tag2"]``` to skip or target specific features as required.