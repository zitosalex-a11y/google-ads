#!/usr/bin/env bash
# Launches Google's official Google Ads MCP server (github.com/googleads/google-ads-mcp)
# over stdio. Credentials come from environment variables; see README.md.
#
# stdout is the MCP protocol channel, so everything else goes to stderr.
set -euo pipefail

# Pinned upstream commit; bump deliberately after reviewing upstream changes.
GOOGLE_ADS_MCP_REF="${GOOGLE_ADS_MCP_REF:-0b78c0caa6d1dfbd21817487c7e571514c627c87}"
SPEC="git+https://github.com/googleads/google-ads-mcp.git@${GOOGLE_ADS_MCP_REF}"

log() { echo "[google-ads-mcp] $*" >&2; }

if [[ -z "${GOOGLE_ADS_DEVELOPER_TOKEN:-}" ]]; then
  log "GOOGLE_ADS_DEVELOPER_TOKEN is not set; API calls will fail."
fi

# The server authenticates with Application Default Credentials. When no ADC
# file is provided, build an "authorized_user" one from the OAuth env vars.
if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]]; then
  if [[ -n "${GOOGLE_ADS_CLIENT_ID:-}" && -n "${GOOGLE_ADS_CLIENT_SECRET:-}" && -n "${GOOGLE_ADS_REFRESH_TOKEN:-}" ]]; then
    umask 077
    creds_file="$(mktemp "${TMPDIR:-/tmp}/google-ads-adc.XXXXXX")"
    trap 'rm -f "$creds_file"' EXIT
    python3 - "$creds_file" <<'PY'
import json, os, sys
with open(sys.argv[1], "w") as f:
    json.dump({
        "type": "authorized_user",
        "client_id": os.environ["GOOGLE_ADS_CLIENT_ID"],
        "client_secret": os.environ["GOOGLE_ADS_CLIENT_SECRET"],
        "refresh_token": os.environ["GOOGLE_ADS_REFRESH_TOKEN"],
    }, f)
PY
    export GOOGLE_APPLICATION_CREDENTIALS="$creds_file"
  else
    log "No credentials: set GOOGLE_ADS_CLIENT_ID, GOOGLE_ADS_CLIENT_SECRET and"
    log "GOOGLE_ADS_REFRESH_TOKEN (or GOOGLE_APPLICATION_CREDENTIALS)."
  fi
fi

# Run in a subprocess (not exec) so the EXIT trap removes the temp credentials.
if command -v uvx >/dev/null 2>&1; then
  uvx --quiet --from "$SPEC" google-ads-mcp
elif command -v pipx >/dev/null 2>&1; then
  pipx run --spec "$SPEC" google-ads-mcp
else
  log "Neither uvx nor pipx found. Install uv: https://docs.astral.sh/uv/"
  exit 1
fi
