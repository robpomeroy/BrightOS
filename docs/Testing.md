# Testing with Molecule

This guide covers setting up and running the Molecule test framework for the BrightOS Ansible playbook. After a few years of evolution, we now support testing exclusively via **Hyper-V on Windows**, ensuring compatibility with modern development environments.

## Quick Start

If you already have Hyper-V and Vagrant set up, jump to [Running Tests](#running-tests).

## Prerequisites

### System Requirements

- **Windows 10 or later** with Hyper-V enabled (Home, Pro, Enterprise, or Education editions; Home edition requires Hyper-V workarounds)
- **WSL2** ([Enable WSL](https://learn.microsoft.com/en-gb/windows/wsl/install))
- **Administrator privileges** (for Vagrant and Hyper-V)

### Software Installation (WSL2)

Start WSL2 and elevate to root with `sudo -i`, then perform these once:

```bash
# Full system upgrade
apt update && apt -y upgrade

# Install Python, development tools, and prerequisites
apt install -y python3 python3-pip python3-dev python3-virtualenv shellcheck
```

### Install Vagrant on Windows Host

**Important:** Vagrant must be installed on your **Windows host**, not in WSL. The Hyper-V provider is Windows-only and will not work with a Linux-based Vagrant installation in WSL.

Install Vagrant on Windows by downloading the installer from [HashiCorp's Vagrant downloads](https://developer.hashicorp.com/vagrant/downloads), or use Chocolatey:

```powershell
# On Windows (PowerShell as Administrator):
choco install vagrant
```

Once installed on Windows, you can invoke Vagrant from WSL using the `VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1` environment variable (see "Setup for Windows Host Access" section below).

**Optional WSL setup (for Ansible and development tools only):**

If you prefer to run Ansible and Molecule from WSL, install these lightweight dependencies in WSL— but **do not install Vagrant in WSL**:

```bash
# In WSL, install optional development tools
apt install -y git python3-pip
```

### Install Ansible and Molecule

Exit root (`Ctrl-D`) and set up a Python virtual environment:

```bash
# Create virtual environment
mkdir -p ~/venv
cd ~/venv
virtualenv -p python3 brightos-test

# Activate it
source ~/venv/brightos-test/bin/activate

# Install required Python packages
pip install ansible-builder ansible-lint ansible-navigator jmespath molecule molecule-vagrant python-vagrant pyvmomi PyYAML testinfra yamllint

# To deactivate later, run: deactivate
```

### Setup for Windows Host Access (WSL2)

To invoke the Windows-installed Vagrant from WSL2 and allow it to access both the BrightOS repository and Windows Hyper-V infrastructure, add this environment variable to WSL:

```bash
# Add to ~/.bashrc (within WSL):
echo 'export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"' >> ~/.bashrc

# Apply changes:
source ~/.bashrc
```

This allows the Windows Vagrant executable to seamlessly access your repository files in WSL and Hyper-V on the Windows host.

### Enable Hyper-V (Windows Host)

Ensure Hyper-V is enabled on your Windows machine. Open PowerShell as Administrator and run:

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

If you're on Windows 10 Home, you may need to use [Hyper-V on Home](https://github.com/microsoft/Hyper-V-on-Windows10-Home).

## Understanding Scenarios

Molecule tests are organized into **scenarios**, each with a specific OS and test configuration. We currently provide:

- **`default`** ← Run this for most development work
  - Provider: Hyper-V
  - OS: Ubuntu Server 24.04 (bento/ubuntu-24.04)
  - Use case: Primary development and testing

- **`hyperv_almalinux10`**
  - Provider: Hyper-V
  - OS: AlmaLinux 10 (almalinux/10)
  - Use case: Red-Hat-based compatibility testing

To run a specific scenario, use `-s <scenario_name>`. For example:

```bash
molecule test -s hyperv_almalinux10
```

Running `molecule test` (without `-s`) runs the `default` scenario.

## Hyper-V Virtual Switch Configuration

On first use, **Vagrant will interactively prompt for a Hyper-V virtual switch**. You can:

1. **Accept the default (Recommended for most users):** Press Enter when prompted; Vagrant will use the "Default Switch".
2. **Use a named switch:** Create a switch in Hyper-V Manager beforehand, then specify it when prompted.
3. **Hard-code the switch (Advanced):** Edit `molecule/default/molecule.yml` and uncomment the `provider_raw_config_args` section:

   ```yaml
   provider_raw_config_args:
     - "switch_name=Default Switch"
   ```

   Replace `"Default Switch"` with your switch's name. Repeat for other scenarios.

## Running Tests

Ensure you're in the repository root and have activated your virtual environment:

```bash
cd /path/to/BrightOS
source ~/venv/brightos-test/bin/activate
```

### Full Test Cycle

```bash
# Run the complete test (create, converge, idempotence, verify, destroy)
molecule test -s default

# Run against AlmaLinux 10
molecule test -s hyperv_almalinux10
```

### Step-by-Step Testing

For development and debugging, run phases individually:

```bash
# Create the test VM
molecule create -s default

# Run the playbook against the VM
molecule converge -s default

# Test idempotence (run the playbook twice, verify it's stable)
molecule idempotence -s default

# Run verification tests (currently just asserts true; expand as needed)
molecule verify -s default

# Clean up the VM
molecule destroy -s default
```

### Linting

Before committing, lint your code:

```bash
# Lint all YAML files and Ansible roles
molecule lint -s default

# This runs:
# - yamllint (YAML syntax)
# - ansible-lint (Ansible best practices, with some rules excluded)
```

## Advanced Usage

### Vagrant Snapshots

Snapshots allow you to save a VM state and restore it quickly, useful for iterative development:

```bash
# After 'molecule create', get the VM UUID
vagrant global-status

# Save a snapshot (replace <uuid> and <name>)
vagrant snapshot save <uuid> <snapshot_name>

# Restore a snapshot
vagrant snapshot restore <uuid> <snapshot_name>

# Delete a snapshot
vagrant snapshot delete <uuid> <snapshot_name>
```

### Debugging a Failed Convergence

If the playbook fails during `molecule converge`:

1. **Keep the VM alive** — only run `molecule destroy` when ready to detach
2. **SSH into the VM:**
   ```bash
   vagrant global-status
   vagrant ssh <uuid>
   ```
   Once inside, you can inspect logs, check installed packages, and re-run commands manually.
3. **Edit the playbook** as needed, then re-run `molecule converge`.

### Using molecule-docker Locally (Optional)

If you prefer Docker over Hyper-V VMs (e.g., on non-Windows systems), you can install `molecule-docker` in your venv:

```bash
pip install molecule-docker
```

Then create a scenario using the Docker driver. This is **unsupported** for BrightOS development but may be useful for quick linting checks.

## Troubleshooting

### Vagrant Prompt Hangs on WSL2

If Vagrant hangs when prompting for the Hyper-V switch, ensure:

1. You're running within WSL2 (not PowerShell)
2. `VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1` is set in your environment
3. Your Windows host is accessible from WSL: test with `ls /mnt/c/`

### almalinux/10 Box Not Available

AlmaLinux 10 is very recent (2024/2025). If `vagrant up` fails with "box not found" or "no provider", you have options:

1. **Wait for bento:** The [Bento project](https://app.vagrantup.com/bento) periodically boxes new OS releases; check if `bento/almalinux-10` is available.
2. **Build manually:** Use the official AlmaLinux ISO and Vagrant's `vagrant package` command (advanced).
3. **Use AlmaLinux 9** temporarily by editing `molecule/hyperv_almalinux10/molecule.yml` and changing the `box` to `almalinux/9`.

### Permission Denied Errors

If you see permission errors, ensure:

1. You're running `vagrant` commands from WSL2 with admin privileges
2. Hyper-V is enabled and accessible
3. The repository is on your local drive (C:), not a network share

## Next Steps

- Review the [main playbook](../main.yml) to understand what roles are tested.
- Expand [verify.yml](../molecule/resources/playbooks/verify.yml) with real test assertions (currently it only asserts `true`).
- Check [config.yml.example](../config.yml.example) and [ansible.cfg.example](../ansible.cfg.example) to customize test settings.

For feedback or issues, consult the [Molecule documentation](https://molecule.readthedocs.io).
