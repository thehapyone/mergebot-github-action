# Mergebot GitHub Action

![Continuous Integration](https://github.com/thehapyone/mergebot-github-action/actions/workflows/ci.yml/badge.svg)
![Lint](https://github.com/thehapyone/mergebot-github-action/actions/workflows/linter.yml/badge.svg)

Reusable GitHub Action that runs the official [`thehapyone/mergebot`](https://github.com/thehapyone/Mergebot) container inside your workflows. Point it at your Mergebot config (or let it autodetect the current repo) and it will execute `mergebot ondemand` with your GitHub App credentials. The action image is pinned to `thehapyone/mergebot:v0.2.0` for deterministic runs, and Dependabot is configured to open upgrade PRs when new tags are pushed.

> **Prerequisites**
>
> - Mergebot GitHub App installed on your organization/repository
> - Secrets storing the App ID and private key (see [`docs/usage/onboarding.md`](https://github.com/thehapyone/Mergebot/blob/main/docs/usage/onboarding.md))

## Quick Start

```yaml
name: Mergebot PR Analysis

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  mergebot:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: thehapyone/mergebot-github-action@v1
        with:
          github-app-id: ${{ secrets.GITHUB_APP_ID }}
          github-app-private-key: ${{ secrets.GITHUB_APP_PRIVATE_KEY }}
          # config-path: .github/mergebot/config-github.yaml
          workers: 10
```

### Scheduled / Multi-Repo Runs

```yaml
on:
  schedule:
    - cron: "0 3 * * *"
  workflow_dispatch:

jobs:
  nightly-mergebot:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          repository: your-org/mergebot-configs
      - uses: thehapyone/mergebot-github-action@v1
        with:
          github-app-id: ${{ secrets.GITHUB_APP_ID }}
          github-app-private-key: ${{ secrets.GITHUB_APP_PRIVATE_KEY }}
          config-path: config-github.yaml
          max-concurrency: 4
          workers: 8
```

## Inputs

| Name | Required | Description |
| --- | --- | --- |
| `github-app-id` | ✅ | GitHub App ID created during Mergebot onboarding. |
| `github-app-private-key` | ✅ | Multiline private key (PEM) for the Mergebot App; store as a secret. |
| `github-app-installation-id` |  | Override if auto-discovery fails (self-hosted/GHE). |
| `config-path` |  | Path (relative to the workspace) to a Mergebot config. When omitted the action targets the current repo via `--project`. |
| `project` |  | Manually set the `owner/repo` slug for `--project`. Defaults to `${{ github.repository }}`. |
| `workers` |  | Number of worker threads passed to `mergebot ondemand`. |
| `max-concurrency` |  | Limit concurrent PRs/projects processed per run. |
| `log-level` |  | Mergebot log level (`info`, `debug`, `warn`). Default `info`. |
| `mergebot-command` |  | Advanced: replace `ondemand` with any other Mergebot subcommand. |
| `extra-args` |  | Additional CLI flags, appended verbatim (split on whitespace). |
| `azure-api-key` / `azure-api-base` / `azure-api-version` |  | Optional Azure/OpenAI credentials for LLM providers. |
| `requests-ca-bundle` |  | Path to a CA bundle when routing through corporate proxies. |
| `dry-run` |  | When `true`, the action prints the Mergebot command instead of running it (useful for CI validation). |

## Outputs

This action does not emit outputs. Rely on the Mergebot PR comments/statuses instead.

## Development

```bash
# Build locally
docker build -t mergebot-action .

# Smoke test (dry run skips the actual Mergebot invocation)
docker run --rm \
  -e INPUT_GITHUB_APP_ID=123 \
  -e INPUT_GITHUB_APP_PRIVATE_KEY="test" \
  -e INPUT_DRY_RUN=true \
  mergebot-action
```

### CI & Linting

- `.github/workflows/ci.yml` builds the container and exercises the action in dry-run mode.
- `.github/workflows/linter.yml` runs `super-linter` (includes Dockerfile, ShellCheck, Markdown linting, etc.).

## Versioning & Marketplace

1. Merge changes to `main`.
2. If a new Mergebot image is available, bump `MERGEBOT_VERSION` in `Dockerfile` (Dependabot will usually open this PR).
3. Tag semantic versions (`v1.0.0`) and move the major tag (`v1`) forward.
4. Publish the action to the GitHub Marketplace under the “Code Review” and “Continuous Integration” categories.

Pin to a major version (`@v1`) for stability, or to a full tag/commit for reproducibility.
