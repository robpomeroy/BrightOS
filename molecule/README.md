# Testing with Molecule

## Prerequisites

In order to be able to use the tests, you need to have some software packages installed. You may need sudo privileges for some of these operations.

### manual installation

Run these steps on your terminal.

```bash
### install VirtualBox
# do NOT use distribution packages, as they may be too old!
# process documented at https://www.virtualbox.org/wiki/Linux_Downloads
#
# add GPG key
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
# add repository URL
sudo echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian stretch contrib" > /etc/apt/sources.d/virtualbox.list
# update sources and install VirtualBox
sudo apt update; sudo apt-get install virtualbox-6.1

### install Vagrant
# do NOT use distribution packages, as they may be too old!
# 
# download Debian package from Hashicorp, replace version number with latest version
wget https://releases.hashicorp.com/vagrant/2.2.9/vagrant_2.2.9_x86_64.deb
# install package
sudo dpkg -i vagrant_2.2.9_x86_64.deb

### install Molecule et. al.
# prepare directories
mkdir ~/python-envs/ && cd ~/python-env/
# create Python Virtual Environment with Python3 interpreter (Python2 is deprecated!)
virtualenv -p python3 molecule-env
# enter the Virtual Environment in your current shell (other shells will be unaffected)
source molecule-env/bin/activate
# install packages
pip3 install molecule ansible testinfra ansible-lint molecule-vagrant molecule-docker

# leave the Virtual Environment only when you're done
deactivate
```

You can find suitable documentation at the respective vendors' websites.
* [Vagrant Installation Guide](https://www.vagrantup.com/docs/installation/)
* [VirtualBox Installation Guide](https://www.virtualbox.org/wiki/Downloads)
* [Molecule Installation Guide](https://molecule.readthedocs.io/en/stable/installation.html)

## Initialising a new Molecule scenario

If you have already created a role without the Molecule test framework or you want to add test scenarios, you can use:
```bash
molecule init scenario --scenario-name <my_scenario> --driver [azure|delegated|docker|ec2|gce|linode|lxc|lxd|openstack|vagrant] --verifier-name [ansible|testinfra]
```

If you need any help with the options, please use:
```bash
molecule init role --help
```

## Running Tests

Molecule helps with creating a test infrastructure, running tests against it and removing the test infrastructure afterwards.

Various test environments are separated into so-called "scenarios" that can be based on different OSses, drivers, verifiers or might just differ in a minor detail. 

In the simplest configuration, the `molecule/` directory only contains one `default/` directory that contains the default scenario. This scenario is run if no other scenario is chosen using the `-s` CLI option.

This is the basic usage of Molecule:
```bash
# create test infrastructure
cd <role_directory>
molecule create
# run playbooks against test infrastructure
molecule converge
# run idempotence tests
molecule idempotence
# run tests, if they exist
molecule verify
# remove test infrastructure
molecule destroy

# run all steps at once:
molecule test
```

It has proven helpful to use Vagrant to create a snapshot of the VM after the creation phase has completed. Just like this:
```bash
# First, get UUID of the VM
vagrant global-status
# Then, create the snapshot
vagrant snapshot save <uuid> <snapshot_name>
# To restore the snapshot, use
vagrant snapshot restore <uuid> <snapshot_name>
# And to remove the snapshot, use
vagrant snapshot delete <uuid> <snapshot_name>
```
