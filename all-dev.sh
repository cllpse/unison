#!/usr/bin/env bash
# Stops whatever the last run started, then runs every watcher plus the web playground, Expo playground and website dev
# servers in parallel, each output line prefixed with its name, until Ctrl+C. Their pids are logged to .all-dev.pids,
# which the next run reads to stop them, from any terminal.

set -euo pipefail
cd "$(dirname "$0")"

pid_file=.all-dev.pids

# One line per script: the name its output is prefixed with, the submodule, and the script to run there.
scripts="components:sync-watch:plugin unison-components components:sync-watch:plugin
components:sync-watch:playground-web unison-components components:sync-watch:playground-web
components:sync-watch:playground-expo unison-components components:sync-watch:playground-expo
components:generate:tokens:watch unison-components generate:tokens:watch
components:generate:tailwind:watch unison-components generate:tailwind:watch
plugin:watch unison-plugin plugin:watch
playground-web:dev unison-playground-web dev
playground-expo:start unison-playground-expo start
website:dev unison-website dev"

# Run under a pseudo-terminal so the scripts keep their colors even though their output is piped through awk.
with_tty() {
  if [ "$(uname)" = "Darwin" ]; then
    script -q /dev/null "$@"
  else
    script -qefc "$(printf '%q ' "$@")" /dev/null
  fi
}

stop() {
  if [ ! -s "$pid_file" ]; then
    echo "Nothing to stop: no $pid_file"
    return
  fi
  while read -r pid name; do
    [ "$pid" = owner ] && continue
    if kill -HUP -- "-$pid" 2>/dev/null; then
      echo "Stopped $name (pid $pid)"
    else
      echo "$name (pid $pid) was not running"
    fi
  done <"$pid_file"
  # Last, so a run that stops the previous one only ever sees a log of processes that are gone.
  rm -f "$pid_file"
}

# An empty submodule folder (git worktrees start without them) makes bun fall back to the root package.json, which has
# no scripts, so say how to check them out instead.
require_submodules() {
  local missing
  missing=$(git config -f .gitmodules --get-regexp '\.path$' | while read -r _ path; do
    [ -f "$path/package.json" ] || echo "  $path"
  done)
  if [ -n "$missing" ]; then
    printf 'These submodules are not checked out:\n%s\nRun: git submodule update --init --recursive\n' "$missing" >&2
    exit 1
  fi
}

# Runs the scripts in parallel until they all exit or Ctrl+C, logging each one's pid; the log is removed on exit,
# unless a newer run has taken it over by then.
start() {
  local i=0 name dir script prefix
  export FORCE_COLOR=1 CLICOLOR_FORCE=1
  # Job control gives each script its own process group, so one kill stops the script, awk and everything they started.
  set -m
  pids=()
  trap 'for pid in "${pids[@]}"; do kill -HUP -- "-$pid" 2>/dev/null; done
    [ "$(head -n 1 "$pid_file" 2>/dev/null)" != "owner $$" ] || rm -f "$pid_file"' INT TERM EXIT
  echo "owner $$" >"$pid_file"
  while read -r name dir script; do
    prefix=$(printf '\033[%sm[%s]\033[0m ' "$((31 + i % 6))" "$name")
    (with_tty bun run --cwd "$dir" "$script" </dev/null 2>&1 |
      awk -v prefix="$prefix" '{ sub(/\r$/, ""); print prefix $0; fflush() }') &
    pids+=("$!")
    echo "$! $name" >>"$pid_file"
    printf '%sstarted, pid %s\n' "$prefix" "$!"
    i=$((i + 1))
  done <<<"$scripts"
  wait
}

stop
require_submodules
start
