# Testing with Molecule

This directory contains Molecule test scenarios for the BrightOS playbook.
Container scenarios provide fast, reproducible checks, and VM-over-SSH
scenarios can target prebuilt machines for host-accurate validation.

## Available Scenarios

- **`default`** — Ubuntu Server 24.04 in Docker
- **`almalinux`** — AlmaLinux 10 in Docker
- **`vm_ubuntu`** — prebuilt Ubuntu VM over SSH (default driver, unmanaged host)
- **`vm_almalinux`** — prebuilt AlmaLinux 10 VM over SSH (default driver, unmanaged host)

## Getting Started

See **[../docs/Testing.md](../docs/Testing.md)** for comprehensive setup and
usage instructions.

For VM-over-SSH scenarios, use **[../scripts/molecule-vm-env.sh](../scripts/molecule-vm-env.sh)**
with **[../.molecule-vm.env.example](../.molecule-vm.env.example)** to switch
targets quickly.

For a full parallel VM regression run, use:

```bash
scripts/molecule-vm-env.sh run-both
```

This includes:
- Prerequisites and software installation
- How to run tests (full cycle and step-by-step)
- Troubleshooting
- Advanced usage (debugging, logs, and step-by-step runs)

## Scenario Structure

Each scenario directory contains:
- `molecule.yml` — scenario configuration (OS, provider, playbooks to run)

Shared playbooks live in `resources/playbooks/`:
- `prepare.yml` — pre-convergence setup (e.g., install GNOME dependencies)
- `converge.yml` — main playbook execution
- `verify.yml` — post-convergence assertions
