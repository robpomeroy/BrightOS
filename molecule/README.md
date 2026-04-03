# Testing with Molecule

This directory contains Molecule test scenarios for the BrightOS playbook. Each scenario tests the playbook against a specific operating system using Vagrant and Hyper-V.

## Available Scenarios

- **`default`** — Ubuntu Server 24.04 (recommended for most development)
- **`hyperv_almalinux10`** — AlmaLinux 10 (Red Hat compatibility)

## Getting Started

See **[../docs/Testing.md](../docs/Testing.md)** for comprehensive setup and usage instructions.

This includes:
- Prerequisites and software installation
- Hyper-V virtual switch configuration
- How to run tests (full cycle and step-by-step)
- Troubleshooting
- Advanced usage (snapshots, debugging, etc.)

## Quick Reference

From the repository root with your virtual environment activated:

```bash
# Run the complete test cycle on the default scenario
molecule test

# Run against AlmaLinux 10
molecule test -s hyperv_almalinux10

# Run individual phases
molecule create -s default
molecule converge -s default
molecule verify -s default
molecule destroy -s default
```

## Scenario Structure

Each scenario directory contains:
- `molecule.yml` — scenario configuration (OS, provider, playbooks to run)

Shared playbooks live in `resources/playbooks/`:
- `prepare.yml` — pre-convergence setup (e.g., install GNOME dependencies)
- `converge.yml` — main playbook execution
- `verify.yml` — post-convergence assertions (currently minimal)
