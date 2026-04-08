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

BrightOS uses **Docker containers with Molecule** for isolated, reproducible
testing. This approach works on Windows, macOS, and Linux.

**Quick summary:**
1. Install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
2. Enable WSL2 backend in Docker Desktop (Settings → Resources → WSL Integration)
3. Install WSL2 and Python 3 (in WSL)
4. Create a Python virtual environment in WSL and install Ansible + Molecule
   with Docker plugin
5. Run Molecule from WSL:
   ```bash
   molecule test
   ```

For detailed setup instructions, hardware/software requirements,
troubleshooting, and testing workflows, see **[Testing.md](Testing.md)**.
