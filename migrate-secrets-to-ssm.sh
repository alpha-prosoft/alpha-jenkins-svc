#!/bin/bash

set -euo pipefail

# Migrates Jenkins configuration from AWS Secrets Manager to SSM Parameter Store.
#
#   /${env}/jenkins/config    Secrets Manager -> SSM SecureString, restructured to { env, services }
#   /${env}/jenkins/password  Secrets Manager -> SSM SecureString (verbatim)
#
# The old config secret held { services, environment }. The "environment" block is
# dropped (it now comes from the instance /etc/environment.json) and a default "env"
# block is injected so existing global env vars keep working.
#
# Usage: ./migrate-secrets-to-ssm.sh <EnvironmentNameLower> [--apply]
#        Without --apply nothing is written; it only prints the planned changes.

env_lower=${1:?Usage: $0 <EnvironmentNameLower> [--apply]}
apply=false
[[ "${2:-}" == "--apply" ]] && apply=true

ts() { date -u +%FT%TZ; }
log() { echo "[migrate] $(ts) INFO  $*"; }
ok() { echo "[migrate] $(ts) OK    $*"; }
warn() { echo "[migrate] $(ts) WARN  $*" >&2; }
err() { echo "[migrate] $(ts) ERROR $*" >&2; }
rule() { echo "[migrate] ----------------------------------------------------------------"; }

redact() { jq 'walk(if type == "object" and has("password") then .password = "***" else . end)'; }

read -r -d '' DEFAULT_ENV <<'JSON' || true
{
  "GLOBAL_PROPERTIES_DOCKER_BUILD_ARGS": "--build-arg DOCKER_URL=<< services.dockerHttp.url >> --build-arg DOCKER_PUSH_URL=<< services.dockerHttp.pushUrl >> --build-arg DOCKER_ORG=<< services.dockerHttp.org >> --build-arg BUILD_ID=${BUILD_ID} --progress plain --build-arg ARTIFACT_ORG=<< services.artifactDeployHttp.org >>",
  "DOCKER_ORG": "<< services.dockerHttp.org >>",
  "DOCKER_DEV_ORG": "<< services.dockerDevHttp.org >>",
  "DOCKER_PUSH_URL": "<< services.dockerHttp.pushUrl >>",
  "DOCKER_URL": "<< services.dockerHttp.url >>",
  "GERRIT_EMAIL": "jenkins@alpha-prosoft.com",
  "GERRIT_URL": "gerrit.<< environment.PrivateHostedZoneName >>",
  "GERRIT_USER": "jenkins",
  "GLOBAL_JIRA_URL": "<< services.jira.url >>",
  "GLOBAL_REPOSITORY_DEV_URL": "<< services.artifactDeployDevHttp.url >>",
  "GLOBAL_REPOSITORY_PROD_URL": "<< services.artifactDeployHttp.url >>",
  "GLOBAL_REPOSITORY_PUBLIC_URL": "<< services.artifactDeployPublicHttp.url >>",
  "ARTIFACT_ORG": "<< services.artifactDeployHttp.org >>",
  "ARTIFACT_DEV_ORG": "<< services.artifactDeployDevHttp.org >>",
  "ARTIFACT_PUBLIC_ORG": "<< services.artifactDeployPublicHttp.org >>",
  "GLOBAL_GROUP_ID": "<< services.artifactDeployHttp.org >>",
  "CONFIG_FILE_URL": "s3://<< environment.AccountId >>-<< environment.EnvironmentNameLower >>-configuration/accounts.json",
  "AWS_REGION": "<< environment.Region >>",
  "AWS_DEFAULT_REGION": "<< environment.Region >>"
}
JSON

get_secret() {
  aws secretsmanager get-secret-value \
    --secret-id "$1" \
    --query "SecretString" --output text
}

put_param() {
  local name=$1 value=$2
  if [[ "$apply" == true ]]; then
    local version
    version=$(aws ssm put-parameter \
      --name "$name" \
      --type "SecureString" \
      --tier "Intelligent-Tiering" \
      --value "$value" \
      --overwrite \
      --query "Version" --output text)
    ok "Wrote ${name} (version ${version}, ${#value} bytes)"

    local check
    check=$(aws ssm get-parameter --name "$name" --query "Parameter.Version" --output text)
    ok "Verified ${name} now at version ${check}"
  else
    log "[dry-run] would write ${name} as SecureString (${#value} bytes, tier Intelligent-Tiering)"
  fi
}

show_identity() {
  log "Resolving AWS identity"
  local account arn region
  account=$(aws sts get-caller-identity --query "Account" --output text)
  arn=$(aws sts get-caller-identity --query "Arn" --output text)
  region=${AWS_REGION:-${AWS_DEFAULT_REGION:-$(aws configure get region || echo "unset")}}
  log "Account : ${account}"
  log "Identity: ${arn}"
  log "Region  : ${region}"
}

migrate_config() {
  rule
  local secret_id="/${env_lower}/jenkins/config"
  log "Config: reading Secrets Manager secret ${secret_id}"

  local old
  old=$(get_secret "$secret_id")
  log "Config: read ${#old} bytes from source secret"

  local svc_keys env_keys
  svc_keys=$(jq -r '.services // {} | keys | join(", ")' <<<"$old")
  log "Config: services found -> ${svc_keys:-<none>}"

  if ! jq -e '.environment' <<<"$old" >/dev/null; then
    warn "Config: source secret had no 'environment' block (nothing to drop)"
  else
    log "Config: dropping 'environment' block (now sourced from /etc/environment.json)"
  fi

  env_keys=$(jq -r 'keys | length' <<<"$DEFAULT_ENV")
  log "Config: injecting default 'env' block with ${env_keys} variables"

  local new
  new=$(jq -n \
    --argjson env "$DEFAULT_ENV" \
    --argjson services "$(jq '.services // {}' <<<"$old")" \
    '{env: $env, services: $services}')

  log "Config: resulting parameter structure (passwords redacted):"
  redact <<<"$new" | sed 's/^/[migrate]   /'

  put_param "$secret_id" "$new"
}

migrate_password() {
  rule
  local secret_id="/${env_lower}/jenkins/password"
  log "Password: reading Secrets Manager secret ${secret_id}"

  local password
  if password=$(get_secret "$secret_id" 2>/dev/null); then
    log "Password: read ${#password} bytes (value hidden)"
    put_param "$secret_id" "$password"
  else
    warn "Password: no secret at ${secret_id}, skipping"
  fi
}

rule
if [[ "$apply" == true ]]; then
  log "Mode: APPLY (parameters will be written)"
else
  log "Mode: DRY RUN (pass --apply to write to Parameter Store)"
fi
log "Environment: ${env_lower}"
show_identity

migrate_config
migrate_password

rule
ok "Migration complete for environment '${env_lower}'"
[[ "$apply" == true ]] || log "No changes were made. Re-run with --apply to persist."
