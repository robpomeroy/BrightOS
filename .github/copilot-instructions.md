# BrightOS Workspace Instructions

## Scope
These instructions apply to all work in this repository.

## Build And Test
- Prefer running from Linux/WSL where Docker is available.
- For Molecule work, use the project venv and run tests from repo root.
- Canonical commands:
  - `source .venv/bin/activate`
  - `ansible-galaxy collection install -r requirements.yml`
  - `molecule test`
  - `molecule converge`
  - `molecule idempotence`
  - `molecule verify`
- If Docker-backed tests fail unexpectedly, verify `docker ps` first.

## Architecture
- Entry playbook: [main.yml](../main.yml). It orchestrates roles, tags, and pre_tasks.
- Role layout: `roles/<role>/tasks/main.yml` plus optional distro-specific task files (`Debian.yml`, `RedHat.yml`), with handlers in `roles/<role>/handlers/main.yml`.
- Molecule scenario: `molecule/default/molecule.yml` with shared playbooks under `molecule/resources/playbooks/`.

## Ansible Conventions
- Always access facts via `ansible_facts[...]` (fact var injection is disabled).
- Keep tasks idempotent; prefer declarative modules and explicit `changed_when: false` on fact-gathering/read-only commands.
- Guard optional resources (files/services/facts) before mutating them:
  - Use `stat` + `when: <registered>.stat.exists` for files.
  - Use `service_facts` and check `ansible_facts.services[...] is defined` before service operations.
  - Guard fact-dependent conditions with `is defined` when facts may be unavailable.
- For repeated path lists that can collapse to the same value, ensure uniqueness (for example with `| unique`).
- Keep distro branching in include files keyed by `ansible_facts['os_family']`.

## Pitfalls
- Package availability can drift by distro/version (for example Ubuntu 24.04 changes); prefer conditional package names where needed.
- Containerized Molecule runs can differ from VMs (service/systemd/reboot behavior). Guard handlers and service actions accordingly.
- Keep changes minimal and localized; avoid broad refactors unless requested.

## Documentation Map (Link, Don’t Embed)
- Project overview and usage: [README.md](../README.md)
- Install and baseline setup: [docs/INSTALL.md](../docs/INSTALL.md)
- Testing workflow and prerequisites: [docs/Testing.md](../docs/Testing.md)
- Security model: [docs/Security.md](../docs/Security.md)
- Features: [docs/Features.md](../docs/Features.md)
- Contribution context: [docs/Getting involved.md](../docs/Getting%20involved.md)
- Accessibility goals: [docs/Accessibility.md](../docs/Accessibility.md)
- Windows/WSL specifics: [docs/Windows development.md](../docs/Windows%20development.md)
