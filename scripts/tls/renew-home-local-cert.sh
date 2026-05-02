#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
CERT_FILE="${REPO_ROOT}/nginx/certs/home.local.crt"
RENEW_BEFORE_DAYS="${RENEW_BEFORE_DAYS:-30}"
RENEW_BEFORE_SECONDS="$((RENEW_BEFORE_DAYS * 24 * 60 * 60))"

if [[ ! -f "${CERT_FILE}" ]]; then
  echo "Leaf certificate not found. Creating one now."
  bash "${SCRIPT_DIR}/issue-home-local-cert.sh" --reload
  exit 0
fi

if openssl x509 -checkend "${RENEW_BEFORE_SECONDS}" -noout -in "${CERT_FILE}" >/dev/null; then
  echo "No renewal needed. Certificate is valid for more than ${RENEW_BEFORE_DAYS} days."
  exit 0
fi

echo "Certificate expires within ${RENEW_BEFORE_DAYS} days. Renewing..."
bash "${SCRIPT_DIR}/issue-home-local-cert.sh" --reload
