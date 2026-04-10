# Testing with Molecule

This directory contains Molecule test scenarios for the BrightOS playbook. The
default scenario uses Docker containers to test the playbook in an isolated,
reproducible environment. This approach works on Windows, macOS, and Linux
without requiring Hyper-V or virtual machine configuration.

## Available Scenarios

- **`default`** — Ubuntu Server 24.04 (recommended for most development)

## Getting Started

See **[../docs/Testing.md](../docs/Testing.md)** for comprehensive setup and
usage instructions.

This includes:
- Prerequisites and software installation
- Hyper-V virtual switch configuration
- How to run tests (full cycle and step-by-step)
- Troubleshooting
- Advanced usage (snapshots, debugging, etc.)

## Scenario Structure

Each scenario directory contains:
- `molecule.yml` — scenario configuration (OS, provider, playbooks to run)

Shared playbooks live in `resources/playbooks/`:
- `prepare.yml` — pre-convergence setup (e.g., install GNOME dependencies)
- `converge.yml` — main playbook execution
- `verify.yml` — post-convergence assertions (currently minimal)
