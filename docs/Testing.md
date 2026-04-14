# Testing with Molecule

This guide covers setup and execution of Molecule for the BrightOS Ansible playbook.

Testing uses **Docker containers** with Molecule for fast, reproducible test
cycles. This approach can work on Windows, macOS, and Linux without requiring
manual virtual machine configuration.

## Supported Execution Model

Molecule runs tests in Docker containers using the default scenario:
- **Driver**: Docker
- **Platform**: Ubuntu 24.04
- **Tests**: Syntax check, convergence, idempotence, verification

The preferred approach (used by the project maintainer) is to test from a WSL2
Linux environment with a Docker daemon running on Windows.

## Prerequisites

Be sure to copy `config.yml.example` to `config.yml` and update any necessary
configuration values before running tests.

### System Requirements

- Windows 10 or later
- WSL2 installed and configured
- Docker Desktop for Windows installed and running
- Administrator access to enable WSL2 features

### Install Docker Desktop

Download and install from:
https://www.docker.com/products/docker-desktop

Enable WSL2 backend in Docker Desktop settings: Settings → Resources → WSL
Integration → Enable integration with Ubuntu

Verify Docker is accessible from WSL:

```bash
docker ps
```

### Install Linux Tooling in WSL

In WSL:

```bash
sudo apt update && sudo apt -y upgrade
sudo apt install -y python3 python3-pip python3-dev python3-virtualenv git \
    shellcheck
```

Create Python venv for Molecule in WSL:

```bash
mkdir -p ~/venv
cd ~/venv
virtualenv -p python3 brightos-test
source ~/venv/brightos-test/bin/activate

pip install ansible-core ansible-builder ansible-lint ansible-navigator \
    jmespath molecule 'molecule-plugins[docker]' pyyaml testinfra yamllint

# Install Ansible collections required for Docker driver
ansible-galaxy collection install -r /path/to/BrightOS/requirements.yml
```

## Scenario Overview

- `default`: Ubuntu Server 24.04 in Docker

Additional scenarios can be added by creating directories in `molecule/` with
their own `molecule.yml` configurations.

## Running Tests

From WSL, activate the venv and run Molecule:

```bash
cd /path/to/BrightOS
source ~/venv/brightos-test/bin/activate

# Full test cycle
molecule test
```

## Step-by-Step Actions

Run Molecule actions individually for debugging:

```bash
molecule converge     # Apply roles to container
molecule create       # Create and start container
molecule destroy      # Stop and remove container
molecule idempotence  # Verify idempotent run
molecule syntax       # Check playbook syntax
molecule verify       # Run verify playbook
```

## Verification Policy

The verify playbook now checks more than simple package presence. It asserts a
set of safety and accessibility outcomes including firewall state, DNS-related
configuration, proxy enforcement, browser policy, GNOME lockdown settings, and
application visibility policy.

Application visibility and allow/deny checks are driven by variables in
[config.yml.example](../config.yml.example):

- `hidden_desktop_entries`: desktop launchers that should be hidden with
    `NoDisplay=true` when they exist
- `forbidden_packages`: packages that must not be installed
- `forbidden_desktop_entries`: desktop launchers that must not exist

The defaults in [config.yml.example](../config.yml.example) match current
BrightOS behaviour:

- `byobu.desktop`
- `info.desktop`
- `vim.desktop`
- `htop.desktop`

In Molecule, these checks are handled as follows:

- Hidden desktop entries are checked conditionally: if the desktop file exists
    under `/usr/share/applications`, verification asserts that it contains
    `NoDisplay=true`
- Forbidden packages are asserted absent via package facts
- Forbidden desktop entries are asserted absent via file existence checks

This means contributors do not need stubs just to support the policy model.
Most checks validate the real state of the test container. A stub or fixture is
only needed if you deliberately want to exercise a hide-path for a launcher
that never exists in the chosen Molecule image.

When extending these lists, update both [config.yml.example](../config.yml.example)
and [molecule/resources/playbooks/verify.yml](../molecule/resources/playbooks/verify.yml)
only if the verification semantics need to change. If you are only adding new
items to the policy, updating the variables is enough.

## Troubleshooting

### Docker daemon not accessible

Ensure Docker daemon is running on Windows and WSL integration is enabled:

```bash
docker ps
```

If this fails, check:
1. Docker Desktop is running on Windows
2. Docker Desktop → Settings → Resources → WSL Integration → Enable integration
   with Ubuntu

### Module or action not found

Ensure Ansible plugins point to Molecule's molecule_plugins location:

```bash
source ~/venv/brightos-test/bin/activate
cd /path/to/BrightOS
python -c 'import molecule_plugins.docker as m, os; print(os.path.dirname(m.__file__))'
```

Set in `ansible.cfg` if needed:

```ini
[defaults]
library = /path/to/site-packages/molecule_plugins/docker/modules:~/.ansible/plugins/modules
action_plugins = /path/to/site-packages/molecule_plugins/docker/plugins/action:~/.ansible/plugins/action
```

### Container fails to start

Check for Docker resource constraints or conflicts. Restart Docker and retry:

```bash
docker system prune -a  # Warning: removes all unused images/containers
molecule test
```

### Slow performance on Windows

Docker on Windows (via WSL2) can be slower than native Linux Docker. Consider:

- Closing unused applications to free memory
- Increasing Docker Desktop memory allocation (Settings → Resources → Memory)
- Running tests during off-peak machine usage

## Advanced Usage

### Custom Scenarios

Create additional scenarios by adding directories to `molecule/`:

```bash
mkdir -p molecule/custom-scenario
cp molecule/default/molecule.yml molecule/custom-scenario/
```

Edit `molecule/custom-scenario/molecule.yml` to customise:

- Base image (e.g., `rockylinux:9`, `debian:12`)
- Container name
- Volumes or environment variables

Run custom scenario:

```bash
molecule test -s custom-scenario
```

### Debugging Container

Open a shell into a running container for manual inspection:

```bash
# List running containers
docker ps

# Execute shell in container
docker exec -it vm-runner bash

# Or use Molecule's interactive mode
molecule login
```

## Next Steps

- Review [main.yml](../main.yml) to understand tested roles
- Expand [molecule/resources/playbooks/verify.yml](../molecule/resources/playbooks/verify.yml) with real assertions
- Tune [ansible.cfg](../ansible.cfg) for your environment

