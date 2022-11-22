# Installation

## Prerequisites

You will need a machine from which to run Ansible (the "Ansible control"
machine). In addition, your target machine should meet the following
requirements:

* Ubuntu or AlmaLinux installed (preferably minimal, for the cleanest resulst; I
  use Ubuntu Server 22.04 and AlmaLinux 9)
* OpenSSH installed
* A user account set up, with a password and sudo capability
* Public/private keys set up for this user
* python3 and python3-pip installed (don't be tempted to use, e.g. python39 -
  it may not be able to import the libraries Ansible requires for operation)
* An internet connection, to download the necessary additional packages

Having installed your base operating system, it is recommended to update fully.

## Setup and run

In brief (TODO: expand):

1. Edit `config.yml` to suit your preferences (see annotations in that file)
2. In the `ansible.cfg` file, specify your username on the machine to be
   configured and the path for `private_key_file`
3. Enter your target machine[s] DNS name[s] or IP address[es] into `inventory`
4. On your Ansible control machine, run
   `ansible-galaxy install -r requirements.yml` to pull down the required
   external roles
5. Run `ansible-playbook main.yml --ask-become-pass` (once you've run the
   playbook, the default sudo group is given passwordless sudo, so you can drop
   the "`--ask-become-pass`" after that)

The final step will take some considerable time, particularly during the
installation of packages. Unfortunately Ansible does not have good facilities
for showing progress during package installation. Patience will usually be
rewarded; the installation make take minutes or hours, depending on the speed of
your internet connection and hardware.

Note: for advanced use (e.g. during further development of the playbook), you
can use `[--skip-tags "tag1"] [--tags "tag2"]` to skip or target specific
features as required.