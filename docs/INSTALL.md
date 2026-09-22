# Installation

## Prerequisites

You will need a machine from which to run Ansible (the "Ansible control"
machine). You might find my
[ansible-control repo](https://github.com/robpomeroy/ansible-control) a useful
starting point.

### Ansible version requirement

The playbook requires **ansible-core 2.16 or later** on the control machine.
The external `devsec.hardening` collection uses the `password_expire_warn`
parameter of the `ansible.builtin.user` module, which is only supported by
ansible-core 2.16+. With an older ansible-core, the `os_hardening` role fails
with:

> Unsupported parameters for (ansible.builtin.user) module:
> password_expire_warn

Note that ansible-core 2.16+ requires **Python 3.10 or later** on the control
machine. If your system Python is older (for example Python 3.9),
`pip install --upgrade ansible-core` will silently keep the old version
("Requirement already satisfied"). Use a virtual environment built on a newer
Python instead:

```bash
python3.12 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip ansible
ansible-galaxy collection install -r requirements.yml
```

### Other requirements

In addition, your target machine(s) should meet the following
requirements:

* Ubuntu or AlmaLinux installed (preferably minimal, for the cleanest results; I
  use Ubuntu Server 24.04 and AlmaLinux 10)
* OpenSSH installed
* A user account set up, with a password and sudo capability
* Public/private keys set up for this user
* python3 and python3-pip installed
* An internet connection, to download the necessary additional packages

Having installed your base operating system, it is recommended to update fully.

## Setup and run

In brief (TODO: expand):

1. Copy `config.yml.example` to `config.yml` and edit to suit your preferences
   (see annotations in that file)
2. Copy `ansible.cfg.example` to `ansible.cfg`. Edit to specify your username on
   the machine to be configured and the path for your `private_key_file`
3. Copy `inventory.example` to `inventory`. Enter your target machine[s] DNS
   name[s] or IP address[es].
4. On your Ansible control machine, run
   `ansible-galaxy install -r requirements.yml` to pull down the required
   external roles
5. Run `ansible-playbook main.yml --ask-become-pass` (once you've run the
   playbook, the default sudo group is given passwordless sudo, so you can drop
   the "`--ask-become-pass`" after that)

The final step will take a while, particularly during the installation of
packages. Unfortunately Ansible does not have good facilities for showing
progress during package installation. Patience will usually be rewarded; the
installation make take minutes or hours, depending on the speed of your internet
connection and hardware.

Note: for advanced use (e.g. during further development of the playbook), you
can use `[--skip-tags "tag1"] [--tags "tag2"]` to skip or target specific
features as required.
