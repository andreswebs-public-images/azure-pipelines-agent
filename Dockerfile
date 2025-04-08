# syntax=docker/dockerfile:1

FROM fedora:43 AS base

ARG PUID=2000
ARG PGID=2000

ARG AGENT_USERNAME="vsts"

ARG AGENT_INSTALL_DIR="/home/${AGENT_USERNAME}/work"
ENV AGENT_INSTALL_DIR="${AGENT_INSTALL_DIR}"

RUN \
  groupadd \
    --force \
    --gid "${PGID}" \
    "${AGENT_USERNAME}" && \
  useradd \
    --no-user-group \
    --gid "${PGID}" \
    --uid "${PUID}" \
    --comment "" \
    --shell /bin/bash \
    --create-home \
    "${AGENT_USERNAME}"

RUN \
  mkdir -p /etc/sudoers.d && \
  echo "${AGENT_USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${AGENT_USERNAME}"

RUN \
  mkdir -p "/home/${AGENT_USERNAME}/.local/bin" && \
  chown -R "${AGENT_USERNAME}:${AGENT_USERNAME}" "/home/${AGENT_USERNAME}/.local"

COPY --chown="${AGENT_USERNAME}:${AGENT_USERNAME}" ./agent-install.sh "/home/${AGENT_USERNAME}/.local/bin/agent-install"
COPY --chown="${AGENT_USERNAME}:${AGENT_USERNAME}" ./agent-start.sh "/home/${AGENT_USERNAME}/.local/bin/agent-start"

RUN chmod +x "/home/${AGENT_USERNAME}/.local/bin/agent-install"
RUN chmod +x "/home/${AGENT_USERNAME}/.local/bin/agent-start"

RUN \
  dnf install --assumeyes \
    awk curl git unzip jq tar hostname libicu
  # azure-cli buildah

COPY --from=mikefarah/yq /usr/bin/yq /usr/bin/yq

RUN export OS=$(uname -s | tr '[:upper:]' '[:lower:]') && \
    export ARCH=$(uname -m) && \
    curl \
        --fail \
        --silent \
        --location \
        --output "awscliv2.zip" \
        "https://awscli.amazonaws.com/awscli-exe-${OS}-${ARCH}.zip" && \
    unzip -qq awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws/install awscliv2.zip

USER "${AGENT_USERNAME}"

WORKDIR "${AGENT_INSTALL_DIR}"

RUN  "/home/${AGENT_USERNAME}/.local/bin/agent-install"

ENV PATH="/home/${AGENT_USERNAME}/.local/bin:/home/${AGENT_USERNAME}/bin:${PATH}"

ENTRYPOINT [ "agent-start" ]
