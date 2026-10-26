#!/bin/sh
set -eu
KEY_VAR="${1:-}"
HOST="${2:-}"
if [ -z "$KEY_VAR" ] || [ -z "$HOST" ]; then
  echo "Usage: $0 <env-var-name> <ssh-host>" >&2
  exit 1
fi
eval "KEY_VALUE=\"\${$KEY_VAR:-}\""
if [ -z "$KEY_VALUE" ]; then
  echo "$KEY_VAR is not set, skipping SSH key setup" >&2
  exit 0
fi
mkdir -p ~/.ssh
chmod 700 ~/.ssh
if [ -f "$KEY_VALUE" ]; then
  cp "$KEY_VALUE" ~/.ssh/id_ed25519
else
  printf '%s\n' "$KEY_VALUE" | sed 's/\\n/\n/g' | tr -d '\r' > ~/.ssh/id_ed25519
  printf '\n' >> ~/.ssh/id_ed25519
fi
chmod 600 ~/.ssh/id_ed25519
ssh-keygen -y -f ~/.ssh/id_ed25519 >/dev/null 2>&1 || {
  echo "ERROR: $KEY_VAR is not a loadable SSH private key" >&2
  exit 1
}
ssh-keyscan -t ed25519 "$HOST" > ~/.ssh/known_hosts 2>/dev/null || ssh-keyscan "$HOST" > ~/.ssh/known_hosts
