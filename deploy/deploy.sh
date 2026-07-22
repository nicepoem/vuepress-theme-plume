#!/usr/bin/env bash
# 一键构建 VuePress 站点并上传到服务器
# 用法: pnpm deploy:sh  或  bash deploy/deploy.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$ROOT_DIR/docs/.vuepress/dist"
ENV_FILE="$SCRIPT_DIR/.env.deploy"
TARBALL="$SCRIPT_DIR/dist-deploy.tar.gz"

step() { echo -e "\n==> $1"; }
ok() { echo -e "[OK] $1"; }
err() { echo -e "[ERR] $1" >&2; }

load_env() {
  if [[ ! -f "$ENV_FILE" ]]; then
    err "Config not found: $ENV_FILE"
    echo "Copy deploy/.env.deploy.example to deploy/.env.deploy"
    exit 1
  fi

  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
}

build_site() {
  step "Building site"
  cd "$ROOT_DIR"

  if command -v pnpm >/dev/null 2>&1; then
    pnpm docs:build
  elif command -v npm >/dev/null 2>&1; then
    npm run docs:build
  else
    err "pnpm or npm not found"
    exit 1
  fi

  if [[ ! -d "$DIST_DIR" ]]; then
    err "Build failed, dist not found: $DIST_DIR"
    exit 1
  fi

  ok "Build done"
}

ssh_args() {
  SSH_OPTS=(-o StrictHostKeyChecking=accept-new)
  if [[ -n "${DEPLOY_KEY:-}" && -f "$DEPLOY_KEY" ]]; then
    SSH_OPTS+=(-i "$DEPLOY_KEY")
  fi
}

upload_tar() {
  step "Uploading via tar + scp + ssh"

  rm -f "$TARBALL"
  tar -czf "$TARBALL" -C "$DIST_DIR" .
  ok "Local tarball created"

  local remote="${DEPLOY_USER}@${DEPLOY_HOST}"
  local remote_tar="${DEPLOY_PATH}/dist-deploy.tar.gz"
  local port="${DEPLOY_PORT:-22}"

  ssh_args
  scp -P "$port" "${SSH_OPTS[@]}" "$TARBALL" "${remote}:${remote_tar}"
  ssh -p "$port" "${SSH_OPTS[@]}" "$remote" \
    "mkdir -p '${DEPLOY_PATH}' && tar -xzf '${remote_tar}' -C '${DEPLOY_PATH}' && rm -f '${remote_tar}'"

  rm -f "$TARBALL"
  ok "Upload and extract done"
}

upload_rsync() {
  step "Uploading via rsync"

  local port="${DEPLOY_PORT:-22}"
  ssh_args
  local ssh_cmd="ssh -p $port ${SSH_OPTS[*]}"

  rsync -avz --delete -e "$ssh_cmd" "${DIST_DIR}/" \
    "${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}/"
  ok "rsync upload done"
}

upload_scp() {
  step "Uploading via scp"

  local port="${DEPLOY_PORT:-22}"
  ssh_args

  scp -P "$port" -r "${SSH_OPTS[@]}" "${DIST_DIR}/." \
    "${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}/"
  ok "scp upload done"
}

main() {
  cd "$ROOT_DIR"
  load_env

  if [[ -z "${DEPLOY_HOST:-}" || -z "${DEPLOY_USER:-}" || -z "${DEPLOY_PATH:-}" ]]; then
    err "Set DEPLOY_HOST, DEPLOY_USER, DEPLOY_PATH in deploy/.env.deploy"
    exit 1
  fi

  if ! command -v ssh >/dev/null 2>&1 || ! command -v scp >/dev/null 2>&1; then
    err "ssh/scp not found"
    exit 1
  fi

  local method="${DEPLOY_METHOD:-auto}"
  echo "Deploy target: ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PORT:-22}${DEPLOY_PATH}"

  build_site

  case "$method" in
    tar) upload_tar ;;
    rsync) upload_rsync ;;
    scp) upload_scp ;;
    auto)
      if command -v tar >/dev/null 2>&1; then
        upload_tar
      elif command -v rsync >/dev/null 2>&1; then
        upload_rsync
      else
        upload_scp
      fi
      ;;
    *) err "Unknown DEPLOY_METHOD: $method"; exit 1 ;;
  esac

  echo -e "\nDeploy success!"
  echo "Visit: https://wenzhaohui.com"
}

main "$@"
