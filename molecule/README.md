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

From an elevated Windows PowerShell prompt at repository root:

```powershell
# One-time setup for config.yml and collections
.\scripts\Initialize-MoleculeHyperV.ps1

# Run full test cycle
.\scripts\Invoke-MoleculeHyperV.ps1 -Action test -Scenario default

# Run against AlmaLinux 10
.\scripts\Invoke-MoleculeHyperV.ps1 -Action test -Scenario hyperv_almalinux10

# Run individual phases
.\scripts\Invoke-MoleculeHyperV.ps1 -Action create -Scenario default
.\scripts\Invoke-MoleculeHyperV.ps1 -Action converge -Scenario default
.\scripts\Invoke-MoleculeHyperV.ps1 -Action verify -Scenario default
.\scripts\Invoke-MoleculeHyperV.ps1 -Action destroy -Scenario default
```

## Scenario Structure

Each scenario directory contains:
- `molecule.yml` — scenario configuration (OS, provider, playbooks to run)

Shared playbooks live in `resources/playbooks/`:
- `prepare.yml` — pre-convergence setup (e.g., install GNOME dependencies)
- `converge.yml` — main playbook execution
- `verify.yml` — post-convergence assertions (currently minimal)
