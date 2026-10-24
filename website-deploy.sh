#!/usr/bin/env bash
# Bakes the website and the web playground's pages, copies them into the eject.io and cllp-se hosting folders and runs
# `firebase deploy` in both, publishing the live site. The steps live in unison-website/scripts/deploy.ts.

set -euo pipefail
cd "$(dirname "$0")"

exec bun run --cwd unison-website deploy "$@"
