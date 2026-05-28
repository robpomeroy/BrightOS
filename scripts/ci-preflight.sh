#!/usr/bin/env bash
set -euo pipefail

# Run the same baseline checks as GitHub Actions, locally.
# Requires: python3, docker, and network access for package/image pulls.

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is required for Molecule container scenarios." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: docker daemon is not available (is it running?)." >&2
  exit 1
fi

python3 -m venv .venv
. .venv/bin/activate

python -m pip install --upgrade pip
# Molecule docker driver currently expects task metadata that changed in ansible-core 2.18.
pip install 'ansible-core<2.18' ansible-lint yamllint molecule 'molecule-plugins[docker]' testinfra jmespath pyyaml

ansible-galaxy collection install -r requirements.yml

yamllint .
ansible-lint -x no-loop-var-prefix,command-instead-of-module,package-latest,var-naming[no-role-prefix]
shellcheck scripts/molecule-vm-env.sh roles/proxy/files/abp2privoxy.sh

cp -f config.yml.example config.yml

run_scenario() {
  local scenario="$1"
  trap 'molecule destroy -s "$scenario" || true' RETURN
  molecule create -s "$scenario"
  molecule converge -s "$scenario"
  molecule idempotence -s "$scenario"
  molecule verify -s "$scenario"
  trap - RETURN
  molecule destroy -s "$scenario"
}

run_scenario default
run_scenario almalinux

echo "CI pre-flight completed successfully."
