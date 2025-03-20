#!/usr/bin/env bash
# Adapted from: https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops

set -o nounset
set -o errexit
set -o pipefail

AGENT_WORKDIR="${AGENT_WORKDIR:-_temp}"
AGENT_INSTALL_DIR="${AGENT_INSTALL_DIR:-${HOME}/work}"
AGENT_NAME="${AGENT_NAME:-${HOSTNAME}}"
AGENT_POOL="${AGENT_POOL:-Default}"

if [ -n "${AGENT_WORKDIR}" ]; then
  mkdir -p "${AGENT_WORKDIR}"
fi

if [ ! -d "${AGENT_INSTALL_DIR}" ]; then
  >&2 echo "agent not installed"
  exit 1
fi

export VSO_AGENT_IGNORE="AGENT_TOKEN"

cleanup() {
  trap "" EXIT

  if [ -e "${AGENT_INSTALL_DIR}/config.sh" ]; then
    # wait for running jobs to finish
    while true; do
      "${AGENT_INSTALL_DIR}/config.sh" remove \
        --unattended \
        --auth "PAT" \
        --token "${AGENT_TOKEN}" && break
      sleep 30
    done
  fi
}

set +o nounset
# shellcheck disable=SC1091
source "${AGENT_INSTALL_DIR}/env.sh"
set -o nounset

trap "cleanup; exit 0" EXIT
trap "cleanup; exit 130" INT
trap "cleanup; exit 143" TERM

"${AGENT_INSTALL_DIR}/config.sh" \
  --unattended \
  --acceptTeeEula \
  --auth "PAT" \
  --url "${AGENT_URL}" \
  --token "${AGENT_TOKEN}" \
  --agent "${AGENT_NAME}" \
  --pool "${AGENT_POOL}" \
  --work "${AGENT_WORKDIR}" \
  --replace & wait $!

chmod +x "${AGENT_INSTALL_DIR}/run.sh"

"${AGENT_INSTALL_DIR}/run.sh" "$@" & wait $!
