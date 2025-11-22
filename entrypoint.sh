#!/bin/bash
set -euo pipefail

workspace="${GITHUB_WORKSPACE:-/github/workspace}"

required_inputs=(
	"INPUT_GITHUB_APP_ID"
	"INPUT_GITHUB_APP_PRIVATE_KEY"
)

for var in "${required_inputs[@]}"; do
	if [[ -z "${!var:-}" ]]; then
		input_name="${var#INPUT_}"
		echo "::error::Input '${input_name,,}' is required"
		exit 1
	fi
done

export GITHUB_APP_ID="${INPUT_GITHUB_APP_ID}"
export GITHUB_APP_PRIVATE_KEY="${INPUT_GITHUB_APP_PRIVATE_KEY}"

if [[ -n "${INPUT_GITHUB_APP_INSTALLATION_ID:-}" ]]; then
	export GITHUB_APP_INSTALLATION_ID="${INPUT_GITHUB_APP_INSTALLATION_ID}"
fi

if [[ -n "${INPUT_AZURE_API_KEY:-}" ]]; then
	export AZURE_API_KEY="${INPUT_AZURE_API_KEY}"
fi

if [[ -n "${INPUT_AZURE_API_BASE:-}" ]]; then
	export AZURE_API_BASE="${INPUT_AZURE_API_BASE}"
fi

if [[ -n "${INPUT_AZURE_API_VERSION:-}" ]]; then
	export AZURE_API_VERSION="${INPUT_AZURE_API_VERSION}"
fi

if [[ -n "${INPUT_REQUESTS_CA_BUNDLE:-}" ]]; then
	export REQUESTS_CA_BUNDLE="${INPUT_REQUESTS_CA_BUNDLE}"
fi

config_path="${INPUT_CONFIG_PATH:-}"
if [[ -n "$config_path" && "$config_path" != /* ]]; then
	config_path="${workspace%/}/${config_path}"
fi

mergebot_cmd=("mergebot" "${INPUT_MERGEBOT_COMMAND:-ondemand}")

if [[ -n "$config_path" ]]; then
	mergebot_cmd+=("--config" "$config_path")
else
	project="${INPUT_PROJECT:-${GITHUB_REPOSITORY:-}}"
	if [[ -n "$project" ]]; then
		mergebot_cmd+=("--project" "$project")
	fi
fi

if [[ -n "${INPUT_WORKERS:-}" ]]; then
	mergebot_cmd+=("--workers" "${INPUT_WORKERS}")
fi

if [[ -n "${INPUT_MAX_CONCURRENCY:-}" ]]; then
	mergebot_cmd+=("--max-concurrency" "${INPUT_MAX_CONCURRENCY}")
fi

if [[ -n "${INPUT_LOG_LEVEL:-}" ]]; then
	mergebot_cmd+=("--log-level" "${INPUT_LOG_LEVEL}")
fi

if [[ -n "${INPUT_EXTRA_ARGS:-}" ]]; then
	# shellcheck disable=SC2206
	extra_parts=(${INPUT_EXTRA_ARGS})
	mergebot_cmd+=("${extra_parts[@]}")
fi

dry_run_flag="$(echo "${INPUT_DRY_RUN:-false}" | tr '[:upper:]' '[:lower:]')"
if [[ "$dry_run_flag" == "true" ]]; then
	echo "::notice::Dry run enabled. Mergebot command: ${mergebot_cmd[*]}"
	exit 0
fi

echo "::group::Mergebot command"
printf '%q ' "${mergebot_cmd[@]}"
echo
echo "::endgroup::"

exec "${mergebot_cmd[@]}"
