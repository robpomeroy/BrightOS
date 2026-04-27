# Testing with Molecule

This guide covers setup and execution of Molecule for the BrightOS Ansible
playbook.

Playbooks are tested using Molecule. Testing is possible with Docker containers
(for fast, reproducible test cycles) and user-built minimal VMs, for more
thorough testing.

## Supported Execution Model

Molecule runs tests in Docker containers using these scenarios:
- **Driver**: Docker
- **Platforms**:
  - Ubuntu 24.04 (`default` scenario)
  - AlmaLinux 10 (`almalinux` scenario)
- **Tests**: Syntax check, convergence, idempotence, verification

Molecule can also run against prebuilt VMs over SSH using VM scenarios:
- `vm_ubuntu`: Ubuntu VM reachable over SSH
- `vm_almalinux`: AlmaLinux VM reachable over SSH

Use container scenarios for rapid iteration, then validate on VM scenarios
before merge when changes affect host-level behaviour.

The preferred approach (used by the project maintainer) is to test from a WSL2
Linux environment with a Docker daemon running on Windows, and then run VM tests
against VMs built on ESXi. (The hypervisor choice is immaterial; the VMs are
accessed via IP/SSH.)

### Important Container Limitations

Docker-based Molecule scenarios are excellent for fast role validation, but they
cannot faithfully reproduce every host-level behaviour.

Known limits in container scenarios include:

- Service/runtime checks that rely on full init/systemd behaviour (for example,
  `firewalld`, `snapd`, or service enablement semantics)
- Network configuration paths where Docker manages files directly (for example,
  `/etc/resolv.conf`)
- Host identity operations that are restricted in containers (for example,
  hostname changes)
- Some GUI package installs that depend on kernel features, external mirrors,
  or repository combinations not stable in minimal container images

Because of these limits, Molecule assertions include container-aware guards in
some areas. A passing container scenario means role logic is healthy for the
tested paths, but it is not a complete substitute for full VM/system testing.

## Prerequisites

Be sure to copy `config.yml.example` to `config.yml` and update any necessary
configuration values before running tests.

### Suggested System Requirements

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

In WSL (Ubuntu/Debian):

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
- `almalinux`: AlmaLinux in Docker
- `vm_ubuntu`: prebuilt Ubuntu VM over SSH (default driver, unmanaged host)
- `vm_almalinux`: prebuilt AlmaLinux VM over SSH (default driver, unmanaged
  host)

Additional scenarios can be added by creating directories in `molecule/` with
their own `molecule.yml` configurations.

## VM Quick Start

If your VMs already exist and are reachable over SSH, this is the fastest path:

```bash
cd /path/to/BrightOS

# Optional, but recommended when using the project-local Molecule install
source .venv/bin/activate

cp .molecule-vm.env.example .molecule-vm.env
# Edit .molecule-vm.env with your VM hostnames/IPs and SSH key path

# Run one VM target
scripts/molecule-vm-env.sh run ubuntu
scripts/molecule-vm-env.sh run almalinux

# Or run both targets in parallel
scripts/molecule-vm-env.sh run-both
```

Expected logs for parallel runs:

- `.molecule-vm-logs/vm_ubuntu.log`
- `.molecule-vm-logs/vm_almalinux.log`

## Running Tests

From WSL, activate the venv and run Molecule:

```bash
cd /path/to/BrightOS
source ~/venv/brightos-test/bin/activate

# Full test cycle (default scenario)
molecule test -s default

# Full test cycle (RedHat-family scenario)
molecule test -s almalinux

# Full test cycle against a prebuilt Ubuntu VM over SSH
MOLECULE_VM_HOST=192.0.2.10 \
MOLECULE_VM_USER=brightos \
MOLECULE_VM_KEY=~/.ssh/id_ed25519 \
molecule test -s vm_ubuntu

# Full test cycle against a prebuilt AlmaLinux VM over SSH
MOLECULE_VM_HOST=192.0.2.20 \
MOLECULE_VM_USER=brightos \
MOLECULE_VM_KEY=~/.ssh/id_ed25519 \
molecule test -s vm_almalinux
```

## Step-by-Step Actions

Run Molecule actions individually for debugging (replace `default` with
`almalinux` to target the RedHat-family scenario):

```bash
molecule create -s default       # Create and start container
molecule converge -s default     # Apply roles to container
molecule idempotence -s default  # Verify idempotent run
molecule syntax -s default       # Check playbook syntax
molecule verify -s default       # Run verify playbook
molecule destroy -s default      # Stop and remove container
```

For VM-over-SSH scenarios, `create`/`destroy` are intentionally not part of
the test sequence because Molecule does not manage VM lifecycle.

## VM Scenarios (SSH to Prebuilt Machines)

Use these scenarios when you need host-accurate validation for firewall,
network, service startup, and GUI/package behaviour that containers cannot
fully represent.

### Helper Script (Recommended)

To switch between Ubuntu and AlmaLinux VM targets with one command:

1. Copy the template and edit values:

```bash
cp .molecule-vm.env.example .molecule-vm.env
```

2. Load the target in your current shell:

```bash
source scripts/molecule-vm-env.sh ubuntu
# or
source scripts/molecule-vm-env.sh almalinux
```

3. Run Molecule using the selected scenario:

```bash
molecule test -s "$MOLECULE_VM_SCENARIO"
```

If you prefer not to modify the current shell, the helper can also run the
test directly:

```bash
scripts/molecule-vm-env.sh run ubuntu
scripts/molecule-vm-env.sh run almalinux
```

The script exports:

- `MOLECULE_VM_HOST`
- `MOLECULE_VM_USER`
- `MOLECULE_VM_PORT`
- `MOLECULE_VM_KEY`
- `MOLECULE_VM_SSH_COMMON_ARGS`
- `MOLECULE_VM_SCENARIO`

By default it reads `.molecule-vm.env`. You can pass a custom env file path:

```bash
source scripts/molecule-vm-env.sh ubuntu /path/to/custom.env
```

### Running Both VM Tests In Parallel

If you already have both VMs built and reachable, the simplest approach is to
launch both Molecule runs at once and let each write to its own log file:

```bash
scripts/molecule-vm-env.sh run-both
```

That starts these two full test runs concurrently:

- `molecule test -s vm_ubuntu`
- `molecule test -s vm_almalinux`

The helper resolves Molecule in this order:

- `MOLECULE_BIN` if set
- `.venv/bin/molecule` in the current repository
- first `molecule` found on `PATH`

If your system Molecule differs from your project venv, either activate the
venv first or set `MOLECULE_BIN` explicitly, for example:

```bash
export MOLECULE_BIN=/repos/BrightOS/.venv/bin/molecule
scripts/molecule-vm-env.sh run-both
```

Logs are written to:

- `.molecule-vm-logs/vm_ubuntu.log`
- `.molecule-vm-logs/vm_almalinux.log`

The helper waits for both jobs to finish and returns a non-zero exit code if
either scenario fails.

If you want to inspect one target manually in parallel-friendly subshells, you
can also use the `print` mode:

```bash
( eval "$(scripts/molecule-vm-env.sh print ubuntu)" && molecule test -s "$MOLECULE_VM_SCENARIO" ) &
( eval "$(scripts/molecule-vm-env.sh print almalinux)" && molecule test -s "$MOLECULE_VM_SCENARIO" ) &
wait
```

Suggested use:

- Use `run-both` for routine regression runs.
- Use `run` or `print` when you want to debug one VM or customise the command.

### Required Environment Variables

Set these when running `vm_ubuntu` or `vm_almalinux`:

- `MOLECULE_VM_HOST`: VM IP address (preferred — see note below) or DNS name
- `MOLECULE_VM_USER`: SSH username (defaults to `brightos` if omitted)
- `MOLECULE_VM_KEY`: path to private SSH key for that user

Optional:

- `MOLECULE_VM_PORT`: SSH port (default `22`)
- `MOLECULE_VM_SSH_COMMON_ARGS`: extra SSH args (default uses
    `-o StrictHostKeyChecking=accept-new`)

Example:

```bash
export MOLECULE_VM_HOST=192.0.2.10
export MOLECULE_VM_USER=brightos
export MOLECULE_VM_KEY=~/.ssh/id_ed25519
export MOLECULE_VM_PORT=22

molecule test -s vm_ubuntu
```

### Vanilla VM Build Baseline

> **DNS note when running VM scenarios:** The `name` role sets the system
> hostname. If `system_hostname` is not defined in `config.yml`, the role
> defaults to preserving the current hostname (a no-op). If you *do* set
> `system_hostname` to a different value, DHCP/dynamic DNS will re-register the
> machine under the new name after the post-SELinux reboot, making the original
> hostname unresolvable and breaking Ansible's reconnect. To avoid this during
> testing, either leave `system_hostname` unset, set it to the VM's actual
> hostname, or use IP addresses for `MOLECULE_VM_HOST`.

Build from a clean image/snapshot each run where practical.

Ubuntu baseline:

- Install Ubuntu Server 24.04 (minimal is fine)
- Enable SSH server
- Create user `brightos` (or set `MOLECULE_VM_USER` to your chosen account)
- Add your public key to `~/.ssh/authorized_keys`
- Grant passwordless sudo for the SSH user
- Ensure Python 3 is present (`python3`)

AlmaLinux baseline:

- Install AlmaLinux 10 (minimal is fine)
- Enable SSH server
- Create user `brightos` (or set `MOLECULE_VM_USER` to your chosen account)
- Add your public key to `~/.ssh/authorized_keys`
- Grant passwordless sudo for the SSH user
- Ensure Python 3 is present (`python3`)

Recommended preflight before running Molecule:

```bash
ssh -i ~/.ssh/id_ed25519 brightos@192.0.2.10 'python3 --version && sudo -n true'
```

## Verification Policy

The verify playbook asserts a set of safety and accessibility outcomes including
firewall state, DNS-related configuration, proxy enforcement, browser policy,
GNOME lockdown settings, and application visibility policy. Where container
behaviour differs from real hosts, verification tasks are intentionally
scoped/guarded so tests remain meaningful instead of failing for container-only
constraints.

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

These lists currently define verification targets. They are consumed by
[molecule/resources/playbooks/verify.yml](../molecule/resources/playbooks/verify.yml),
and not yet enforced generically by role logic.

When extending these lists, update [config.yml.example](../config.yml.example).
If the current roles do not already enforce the new entries, `molecule verify`
will fail until enforcement tasks are added. Update
[molecule/resources/playbooks/verify.yml](../molecule/resources/playbooks/verify.yml)
only when the verification semantics themselves need to change.

## Troubleshooting

### VM run fails after host reboot step

If a VM run fails to reconnect after reboot, verify that your VM hostname
remains resolvable throughout the run. This can happen when DHCP/DNS
re-registration changes after hostname updates.

Recommended mitigations:

1. Keep `system_hostname` unset in `config.yml` unless you explicitly need to
    change it.
2. If you set `system_hostname`, keep `MOLECULE_VM_HOST` aligned with the name
    your DNS actually serves after reboot.
3. Use VM IPs in `.molecule-vm.env` if your DNS is dynamic or intermittent.

### AlmaLinux 10 proxy package availability

On AlmaLinux 10, `privoxy` is not currently available in the default enabled
repositories used by this project (including EPEL 10 and EPEL testing).

Because Privoxy is part of BrightOS safety guarantees, the role does **not**
make it optional. Instead, RedHat-family EL10 targets use a strict fallback:

1. Attempt repo-based install (`dnf install privoxy`)
2. If unavailable, build and install PCRE 8 from upstream source
3. Build and install Privoxy from upstream source
4. Install the required Privoxy action/filter files and register a
    `privoxy.service` unit

If either repo install or source fallback fails, the run fails.

For VM-backed Molecule scenarios, proxy environment clearing in `prepare` and
`converge` is now opt-in. By default, inherited proxy variables are preserved,
which is safer for environments that require outbound proxies.

If you need to neutralize stale proxy values on reused VMs, set
`molecule_clear_proxy_env=true` for the run, for example:

```bash
scripts/molecule-vm-env.sh run almalinux -- test -s vm_almalinux -e molecule_clear_proxy_env=true
```

### External package mirror intermittency

Some optional GUI package sources (for example, Tux Paint release RPM sources)
can be intermittently unavailable from certain networks. The role rescues these
download failures and continues so the scenario can still validate the rest of
the system state.

### Converge output shows `fatal` before recovery

In Ansible `block`/`rescue` flows, a task may show a `fatal` line and then be
recovered by a rescue task in the same role. Treat final scenario status as
authoritative:

- Scenario pass: Molecule exits with code `0`
- Scenario fail: Molecule exits non-zero and reports a failed action

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

### When container tests are not enough

Use container scenarios for fast feedback during development, then run at least
one full validation pass on a VM (or real host) before merge/release whenever
your change touches:

- Firewall runtime behaviour
- Network manager/resolver behaviour
- GUI stack/package completeness
- Service enablement/startup semantics

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

