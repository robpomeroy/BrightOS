# Windows development

Contributors to BrightOS may work on a variety of platforms. The founder Rob
uses Windows with WSL. If you are working under Windows and wish to contribute
code to this project, or to run the Molecule tests, please undertake the
steps below.


## Enable symbolic links

Unless you follow these steps, you may at some point encounter a message like:

> error: unable to create symlink molecule/default: Permission denied

This error also occurs when attempting to use the repository from a network
share. The only solution to that is to develop on your local (e.g. C:) drive.

1. [Enable Windows developer mode](https://learn.microsoft.com/en-gb/gaming/game-bar/guide/developer-mode) -
   this is required for symbolic link functionality.
2. Install [Git for Windows](https://gitforwindows.org/).
3. Enable symbolic link support. This command enables it globally:
   `git config --global core.symlinks true`.
4. If you already have a copy of the BrightOS repo, you'll need to run,
   from the repo directory: `git config core.symlinks true`.

## Work with Molecule (for testing the playbook)

For Molecule tests, we use Docker and Vagrant/VirtualBox. VirtualBox conflicts
with Hyper-V so Hyper-V must be disabled.

- [Enable WSL](https://learn.microsoft.com/en-gb/windows/wsl/install) (version
  2)
- [Disable Hyper-V](https://learn.microsoft.com/en-us/troubleshoot/windows-client/application-management/virtualization-apps-not-work-with-hyper-v#how-to-disable-hyper-v)
  (if enabled)
- [Install VirtualBox](https://www.virtualbox.org/wiki/Downloads) & extensions
- Install Ubuntu WSL, e.g.:
  [Ubuntu 22.04 WSL](https://apps.microsoft.com/store/detail/ubuntu-22041-lts/9PN20MSR04DW)
- [Install Vagrant](https://developer.hashicorp.com/vagrant/downloads) (and
  reboot)

Having started WSL, elevate with `sudo -i`, then proceed as follows:

```
# Full upgrade
apt update && apt -y upgrade

# Install Python & various requirements
apt install -y python3 python3-pip python3-dev python3-virtualenv libvirt-dev shellcheck

# Install Vagrant (not from the Ubuntu repos - too old) & various modules & plugins
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update && apt install -y vagrant vagrant-libvirt vagrant-mutate
pip install python-vagrant
vagrant plugin install vagrant-disksize

# Add environment variables for Vagrant (log out and in again to pick these up)
echo 'export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"' >> /home/${SUDO_USER}/.bashrc
echo 'export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox:/mnt/c/Windows/System32:/mnt/c/Windows/system32/WindowsPowerShell/v1.0"' >> /home/${SUDO_USER}/.bashrc

# Get the latest Ansible version
apt-add-repository ppa:ansible/ansible
apt install -y ansible
```

Unelevated (`Ctrl-D` to exit `sudo`), set up a Python
[virtual environment](https://docs.python.org/3/tutorial/venv.html):

```
mkdir -p ~/venv
cd ~/venv
virtualenv -p python3 ansible
```

To use that environment in future:

```
cd ~/venv
source ./ansible/bin/activate

# One-time action to install the required Python modules into this virtual environment
pip install ansible-builder ansible-lint ansible-navigator jmespath docker molecule molecule-docker molecule-vagrant pyvmomi PyYAML testinfra yamllint
```

Note: to exit the virtual environment:

```
deactivate
```
