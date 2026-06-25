#!/usr/bin/env bash
# lint-docs.sh — Lint markdown documentation files
#
# Usage: lint-docs.sh <file-or-directory>
#
# Runs markdownlint (via npx) and optionally Vale if installed.
# Returns non-zero if any linter reports errors.
# Config files are resolved relative to this script's directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:?Usage: lint-docs.sh <file-or-directory>}"

if [[ ! -e "${TARGET}" ]]; then
  echo "Error: '${TARGET}' does not exist."
  exit 1
fi

EXIT_CODE=0

if command -v npx &>/dev/null; then
  echo "==> Running markdownlint..."
  if [[ -d "${TARGET}" ]]; then
    LINT_TARGET="${TARGET}/**/*.md"
  else
    LINT_TARGET="${TARGET}"
  fi
  # Exclude .vale directories — they contain downloaded style packages with their own markdown
  if npx --yes markdownlint-cli2 --config "${SCRIPT_DIR}/.markdownlint-cli2.yaml" "${LINT_TARGET}" "#**/.vale/**"; then
    echo "    markdownlint: passed"
  else
    echo "    markdownlint: found issues (see above)"
    EXIT_CODE=1
  fi
else
  echo "==> markdownlint: SKIPPED (npx not found)"
  echo "    Install Node.js to enable markdownlint."
  # markdownlint is required — missing npx is a failure
  EXIT_CODE=1
fi

if command -v vale &>/dev/null; then
  # Auto-download style packages if missing
  if [[ ! -d "${SCRIPT_DIR}/.vale/styles/Google" ]]; then
    echo "==> Vale styles not found — running vale sync..."
    vale --config "${SCRIPT_DIR}/.vale.ini" sync
  fi
  echo "==> Running Vale..."
  if vale --config "${SCRIPT_DIR}/.vale.ini" "${TARGET}"; then
    echo "    Vale: passed"
  else
    echo "    Vale: found issues (see above)"
    EXIT_CODE=1
  fi
else
  echo "==> Vale: SKIPPED (not installed)"
  echo "    Vale is optional but recommended for prose quality checks."
  echo "    See linting.md for setup instructions."
fi

exit "${EXIT_CODE}"
