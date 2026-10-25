#!/usr/bin/env bash
# Bakes the website and the web playground's pages, copies them into the eject.io and cllp-se hosting folders and runs
# `firebase deploy` in both, publishing the live site. The steps live in unison-website/scripts/deploy.ts.

set -euo pipefail
cd "$(dirname "$0")"

# The bake uses whatever the two submodules have checked out, so pulling the root without updating them would publish
# an older page without a word. Refuse unless each one is checked out and includes the commit the root records; a
# checkout ahead of it, with commits the root isn't bumped to yet, still deploys. --merge in the hint fast-forwards the
# submodule's branch instead of detaching it.
require_recorded_commits() {
  local path recorded stale=""
  for path in unison-website unison-playground-web; do
    recorded=$(git rev-parse ":$path")
    if [ ! -f "$path/package.json" ]; then
      stale+="  $path is not checked out"$'\n'
    elif ! git -C "$path" merge-base --is-ancestor "$recorded" HEAD 2>/dev/null; then
      stale+="  $path is on $(git -C "$path" rev-parse --short HEAD), which doesn't include ${recorded:0:7}"$'\n'
    fi
  done
  if [ -n "$stale" ]; then
    printf 'Not deploying, these submodules are behind the commits the root records:\n%s' "$stale" >&2
    printf 'Run: git submodule update --init --recursive --merge\n' >&2
    exit 1
  fi
}

require_recorded_commits
exec bun run --cwd unison-website deploy "$@"
