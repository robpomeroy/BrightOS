#!/usr/bin/env bash

usage() {
  cat <<'EOF'
Usage:
  source scripts/molecule-vm-env.sh <ubuntu|almalinux> [env-file]
  scripts/molecule-vm-env.sh print <ubuntu|almalinux> [env-file]
  scripts/molecule-vm-env.sh run <ubuntu|almalinux> [env-file] [-- molecule-args...]
  scripts/molecule-vm-env.sh run-both [env-file]

Modes:
  source/load  Load one target into the current shell.
  print        Print export statements for one target.
  run          Run Molecule for one target with loaded env.
  run-both     Run Ubuntu and AlmaLinux VM scenarios in parallel.

Examples:
  source scripts/molecule-vm-env.sh ubuntu
  eval "$(scripts/molecule-vm-env.sh print almalinux)"
  scripts/molecule-vm-env.sh run ubuntu
  scripts/molecule-vm-env.sh run-both
EOF
}

load_env_file() {
  local env_file="$1"

  if [[ -f "${env_file}" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "${env_file}"
    set +a
  fi
}

first_set_value() {
  local default_value="$1"
  shift

  local var_name
  for var_name in "$@"; do
    if [[ -n "${var_name}" && -n "${!var_name:-}" ]]; then
      printf '%s\n' "${!var_name}"
      return 0
    fi
  done

  printf '%s\n' "${default_value}"
}

resolve_target() {
  local target="$1"

  case "${target}" in
    ubuntu)
      MOLECULE_VM_SCENARIO="vm_ubuntu"
      TARGET_PREFIX="MOLECULE_VM_UBUNTU"
      ;;
    almalinux|alma)
      MOLECULE_VM_SCENARIO="vm_almalinux"
      TARGET_PREFIX="MOLECULE_VM_ALMALINUX"
      ;;
    *)
      echo "Unknown target: ${target}" >&2
      echo "Supported targets: ubuntu, almalinux" >&2
      return 1
      ;;
  esac
}

load_target() {
  local target="$1"
  local env_file="$2"
  local host_var
  local user_var
  local port_var
  local key_var
  local ssh_args_var

  load_env_file "${env_file}"
  resolve_target "${target}" || return 1

  host_var="${TARGET_PREFIX}_HOST"
  user_var="${TARGET_PREFIX}_USER"
  port_var="${TARGET_PREFIX}_PORT"
  key_var="${TARGET_PREFIX}_KEY"
  ssh_args_var="${TARGET_PREFIX}_SSH_COMMON_ARGS"

  export MOLECULE_VM_HOST="$(first_set_value "${MOLECULE_VM_HOST:-}" "${host_var}")"
  export MOLECULE_VM_USER="$(first_set_value "${MOLECULE_VM_USER:-brightos}" "${user_var}")"
  export MOLECULE_VM_PORT="$(first_set_value "${MOLECULE_VM_PORT:-22}" "${port_var}")"
  export MOLECULE_VM_KEY="$(first_set_value "${MOLECULE_VM_KEY:-}" "${key_var}")"
  export MOLECULE_VM_SSH_COMMON_ARGS="$(first_set_value "${MOLECULE_VM_SSH_COMMON_ARGS:--o StrictHostKeyChecking=accept-new}" "${ssh_args_var}")"
  export MOLECULE_VM_SCENARIO

  if [[ -z "${MOLECULE_VM_HOST}" ]]; then
    echo "Missing host for target '${target}'." >&2
    echo "Set ${host_var} (or MOLECULE_VM_HOST) in ${env_file}." >&2
    return 1
  fi

  if [[ -z "${MOLECULE_VM_KEY}" ]]; then
    echo "Missing SSH key for target '${target}'." >&2
    echo "Set ${key_var} (or MOLECULE_VM_KEY) in ${env_file}." >&2
    return 1
  fi
}

print_summary() {
  local target="$1"

  echo "Loaded Molecule VM target: ${target}"
  echo "  scenario: ${MOLECULE_VM_SCENARIO}"
  echo "  host:     ${MOLECULE_VM_HOST}"
  echo "  user:     ${MOLECULE_VM_USER}"
  echo "  port:     ${MOLECULE_VM_PORT}"
  echo "  key:      ${MOLECULE_VM_KEY}"
  echo
  echo "Next command: molecule test -s ${MOLECULE_VM_SCENARIO}"
}

print_exports() {
  printf 'export MOLECULE_VM_HOST=%q\n' "${MOLECULE_VM_HOST}"
  printf 'export MOLECULE_VM_USER=%q\n' "${MOLECULE_VM_USER}"
  printf 'export MOLECULE_VM_PORT=%q\n' "${MOLECULE_VM_PORT}"
  printf 'export MOLECULE_VM_KEY=%q\n' "${MOLECULE_VM_KEY}"
  printf 'export MOLECULE_VM_SSH_COMMON_ARGS=%q\n' "${MOLECULE_VM_SSH_COMMON_ARGS}"
  printf 'export MOLECULE_VM_SCENARIO=%q\n' "${MOLECULE_VM_SCENARIO}"
}

run_target() {
  local target="$1"
  local env_file="$2"
  local molecule_bin=""
  shift 2

  load_target "${target}" "${env_file}" || return 1

  if [[ -n "${MOLECULE_BIN:-}" ]]; then
    molecule_bin="${MOLECULE_BIN}"
  elif [[ -x ".venv/bin/molecule" ]]; then
    molecule_bin=".venv/bin/molecule"
  elif command -v molecule >/dev/null 2>&1; then
    molecule_bin="$(command -v molecule)"
  else
    echo "Could not find a Molecule executable." >&2
    echo "Set MOLECULE_BIN or activate your virtual environment first." >&2
    return 1
  fi

  if [[ "$#" -eq 0 ]]; then
    "${molecule_bin}" test -s "${MOLECULE_VM_SCENARIO}"
  else
    "${molecule_bin}" "$@"
  fi
}

run_both_targets() {
  local env_file="$1"
  local log_dir=".molecule-vm-logs"
  local ubuntu_pid
  local alma_pid
  local ubuntu_rc=0
  local alma_rc=0

  mkdir -p "${log_dir}"

  (
    run_target ubuntu "${env_file}"
  ) >"${log_dir}/vm_ubuntu.log" 2>&1 &
  ubuntu_pid=$!

  (
    run_target almalinux "${env_file}"
  ) >"${log_dir}/vm_almalinux.log" 2>&1 &
  alma_pid=$!

  echo "Started parallel Molecule runs:"
  echo "  ubuntu:      PID ${ubuntu_pid}, log ${log_dir}/vm_ubuntu.log"
  echo "  almalinux: PID ${alma_pid}, log ${log_dir}/vm_almalinux.log"

  wait "${ubuntu_pid}" || ubuntu_rc=$?
  wait "${alma_pid}" || alma_rc=$?

  echo
  echo "Run summary:"
  echo "  ubuntu:      exit ${ubuntu_rc}"
  echo "  almalinux: exit ${alma_rc}"

  if [[ "${ubuntu_rc}" -ne 0 || "${alma_rc}" -ne 0 ]]; then
    return 1
  fi
}

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  target="${1:-}"
  env_file="${2:-.molecule-vm.env}"

  if [[ -z "${target}" ]]; then
    usage
    unset target env_file
    return 1
  fi

  if ! load_target "${target}" "${env_file}"; then
    unset target env_file
    return 1
  fi

  print_summary "${target}"
  unset target env_file
  return 0
fi

set -u

mode="${1:-}"

if [[ -z "${mode}" ]]; then
  usage
  exit 1
fi

case "${mode}" in
  print)
    target="${2:-}"
    env_file="${3:-.molecule-vm.env}"
    [[ -n "${target}" ]] || { usage; exit 1; }
    load_target "${target}" "${env_file}" || exit 1
    print_exports
    ;;
  run)
    target="${2:-}"
    env_file=".molecule-vm.env"
    shift 2 || true
    if [[ "${1:-}" != "--" && -n "${1:-}" ]]; then
      env_file="$1"
      shift
    fi
    if [[ "${1:-}" == "--" ]]; then
      shift
    fi
    [[ -n "${target}" ]] || { usage; exit 1; }
    run_target "${target}" "${env_file}" "$@"
    ;;
  run-both)
    env_file="${2:-.molecule-vm.env}"
    run_both_targets "${env_file}"
    ;;
  *)
    usage
    exit 1
    ;;
esac
