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

BrightOS uses **Hyper-V and Vagrant** for isolated, reproducible testing. Hyper-V is available on Windows 10 Pro, Enterprise, Education, and later editions.

We have moved away from VirtualBox because it is incompatible with Hyper-V. **Hyper-V must be enabled** on your Windows machine (it is often disabled by default to avoid conflicts with VirtualBox).

For full step-by-step setup instructions, hardware/software requirements, troubleshooting, and testing workflows, see **[Testing.md](Testing.md)**.

**Quick summary:**
1. [Enable Hyper-V](https://learn.microsoft.com/en-us/windows/security/requirement-based-access-control/virtualization-based-security-enable) on your Windows machine
2. Install WSL2, Vagrant (from HashiCorp repos, not apt), and Python 3
3. Create a Python virtual environment and install Ansible + Molecule packages
4. Run `molecule test -s default` to begin testing

See [Testing.md](Testing.md) for the complete guide.
