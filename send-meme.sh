#!/usr/bin/env bash

set -Eeuo pipefail

readonly MEME_API_URL="https://meme-api.com/gimme"

log() {
  printf '[send-meme] %s\n' "$*" >&2
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "Missing required command: $1"
    exit 1
  fi
}

cleanup_files() {
  rm -f "${FETCH_RESPONSE_FILE:-}" "${POST_RESPONSE_FILE:-}" "${PAYLOAD_FILE:-}"
}

fetch_meme_url() {
  FETCH_RESPONSE_FILE=$(mktemp)

  log "Fetching meme metadata"
  curl \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    --retry-all-errors \
    --connect-timeout 10 \
    --max-time 30 \
    --output "$FETCH_RESPONSE_FILE" \
    "$MEME_API_URL"

  local meme_url
  meme_url=$(jq -er '.url' "$FETCH_RESPONSE_FILE")

  if [[ ! "$meme_url" =~ ^https?:// ]]; then
    log "Meme API returned an invalid URL"
    return 1
  fi

  printf '%s\n' "$meme_url"
}

post_meme() {
  local meme_url="$1"
  PAYLOAD_FILE=$(mktemp)
  POST_RESPONSE_FILE=$(mktemp)

  jq -n --arg content "$meme_url" '{content: $content}' > "$PAYLOAD_FILE"

  log "Posting meme to Discord"

  local http_code
  http_code=$(curl \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    --retry-all-errors \
    --connect-timeout 10 \
    --max-time 30 \
    --output "$POST_RESPONSE_FILE" \
    --write-out '%{http_code}' \
    --header 'Content-Type: application/json' \
    --data @"$PAYLOAD_FILE" \
    "$WEBHOOK")

  if [[ ! "$http_code" =~ ^2 ]]; then
    log "Discord webhook returned HTTP $http_code"
    if [[ -s "$POST_RESPONSE_FILE" ]]; then
      log "Discord response body:"
      cat "$POST_RESPONSE_FILE" >&2
    fi
    return 1
  fi

  log "Posted meme successfully"
}

main() {
  trap cleanup_files EXIT

  require_command curl
  require_command jq

  : "${WEBHOOK:?WEBHOOK secret is required}"

  local meme_url
  meme_url=$(fetch_meme_url)
  log "Fetched meme URL: $meme_url"
  post_meme "$meme_url"
}

main "$@"
