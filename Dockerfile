# Base Mergebot runtime image includes the CLI and dependencies.
ARG MERGEBOT_VERSION=v0.2.0
FROM thehapyone/mergebot:${MERGEBOT_VERSION}

WORKDIR /action

COPY --chmod=0755 entrypoint.sh /action/entrypoint.sh

ENTRYPOINT ["/action/entrypoint.sh"]
