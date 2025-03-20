#!/usr/bin/env bash

# See for artifact name:
# https://github.com/microsoft/azure-pipelines-agent/releases

set -o nounset
set -o errexit
set -o pipefail

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
if [ "${OS}" = "darwin" ]; then
    OS="osx"
fi

ARCH=$(uname -m)
if [ "${ARCH}" = "aarch64" ]; then
    ARCH="arm64"
elif [ "${ARCH}" = "x86_64" ]; then
    ARCH="x64"
fi

REPO="microsoft/azure-pipelines-agent"

function install_if_not_present {
    local cmd="${1}"
    local sudo_cmd=""
    if command -v sudo &> /dev/null; then
        sudo_cmd="sudo"
    fi
    if ! command -v "${cmd}" &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            $sudo_cmd apt-get update > /dev/null 2>&1
            $sudo_cmd apt-get install --yes --quiet "${cmd}"
        fi
        if command -v dnf &> /dev/null; then
            $sudo_cmd dnf install --assumeyes "${cmd}"
        fi
    fi
}

for tool in curl jq tar; do
  install_if_not_present "${tool}"
done

LATEST_TARBALL_URL=$(curl --silent "https://api.github.com/repos/${REPO}/releases/latest" | jq -r .tarball_url)
AGENT_VERSION_LATEST=$(grep -o '[^/v]*$' <<< "${LATEST_TARBALL_URL}")
AGENT_VERSION="${AGENT_VERSION:-${AGENT_VERSION_LATEST}}"

# Alternative:
# AGENT_PACKAGE_NAME_PREFIX="vsts-agent" ## this contains post-EOL NodeJS runtimes
# See: https://github.com/microsoft/azure-pipelines-agent/blob/master/docs/node6.md
AGENT_PACKAGE_NAME_PREFIX="${AGENT_PACKAGE_NAME_PREFIX:-pipelines-agent}"

BASE_DOWNLOAD_URL="https://vstsagentpackage.azureedge.net/agent"
FILE_NAME="${AGENT_PACKAGE_NAME_PREFIX}-${OS}-${ARCH}-${AGENT_VERSION}.tar.gz"
DOWNLOAD_URL="${BASE_DOWNLOAD_URL}/${AGENT_VERSION}/${FILE_NAME}"

WORKDIR=$(mktemp -d -t "${AGENT_PACKAGE_NAME_PREFIX}.XXXXXXXXX")
TMP_FILE="${WORKDIR}/${FILE_NAME}"

AGENT_INSTALL_DIR="${AGENT_INSTALL_DIR:-${HOME}/work}"

function finish {
    rm -rf "${WORKDIR}"
}

trap finish EXIT

curl --fail --silent --location --output "${TMP_FILE}" "${DOWNLOAD_URL}"
mkdir -p "${AGENT_INSTALL_DIR}"
tar --extract --gzip --file="${TMP_FILE}" --directory="${AGENT_INSTALL_DIR}"
