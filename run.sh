#!/usr/bin/env bash
# Pick one or more root package.json scripts and run them.
# Several picks run in parallel with colored, prefixed output; pass --sequential to run them one after another instead.
# Uses gum (Space or x to select, Enter to run) when installed, then fzf, otherwise a numbered menu.
#
# local:start runs every *watch* script plus playground-web:dev and playground-expo:start in parallel and logs their
# pids to .local.pids, after first running local:stop; local:stop (from any terminal) kills the logged processes and
# then clears the log. Both are listed first in the picker.

set -euo pipefail
cd "$(dirname "$0")"

pid_file=.local.pids

# Run under a pseudo-terminal so the scripts keep their colors even though their output is piped through awk.
with_tty() {
  if [ "$(uname)" = "Darwin" ]; then
    script -q /dev/null "$@"
  else
    script -qefc "$(printf '%q ' "$@")" /dev/null
  fi
}

# Runs the newline-separated script names in $1 in parallel until they all exit or Ctrl+C. With a file in $2, also
# logs each script's pid there and removes the file on exit, unless a newer local:start has taken it over by then.
run_parallel() {
  local names=$1 i=0 name prefix
  log=${2:-}
  export FORCE_COLOR=1 CLICOLOR_FORCE=1
  # Job control gives each script its own process group, so one kill stops the script, awk and everything they started.
  set -m
  pids=()
  trap 'for pid in "${pids[@]}"; do kill -HUP -- "-$pid" 2>/dev/null; done
    [ -z "$log" ] || [ "$(head -n 1 "$log" 2>/dev/null)" != "owner $$" ] || rm -f "$log"' INT TERM EXIT
  [ -z "$log" ] || echo "owner $$" >"$log"
  while IFS= read -r name; do
    prefix=$(printf '\033[%sm[%s]\033[0m ' "$((31 + i % 6))" "$name")
    (with_tty bun run "$name" </dev/null 2>&1 |
      awk -v prefix="$prefix" '{ sub(/\r$/, ""); print prefix $0; fflush() }') &
    pids+=("$!")
    if [ -n "$log" ]; then
      echo "$! $name" >>"$log"
      printf '%sstarted, pid %s\n' "$prefix" "$!"
    fi
    i=$((i + 1))
  done <<<"$names"
  wait
}

local_start() {
  local_stop
  run_parallel "$(printf '%s\n' "$scripts" | grep -E 'watch|^playground-web:dev$|^playground-expo:start$')" "$pid_file"
}

local_stop() {
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
  # Last, so a local:start that runs this first only ever sees a log of processes that are gone.
  rm -f "$pid_file"
}

scripts=$(bun -e 'console.log(Object.keys(require("./package.json").scripts).join("\n"))')

case "${1:-}" in
local:start)
  local_start
  exit 0
  ;;
local:stop)
  local_stop
  exit 0
  ;;
esac

sequential=false
if [ "${1:-}" = "--sequential" ] || [ "${1:-}" = "-s" ]; then
  sequential=true
fi

choices=$(printf 'local:start\nlocal:stop\n%s\n' "$scripts")

if command -v gum >/dev/null 2>&1; then
  picked=$(printf '%s\n' "$choices" | gum choose --no-limit --height 20 --header "Space to select, Enter to run") ||
    exit 0
elif command -v fzf >/dev/null 2>&1; then
  picked=$(printf '%s\n' "$choices" | fzf --multi --prompt "scripts> " --header "Tab to select, Enter to run") || exit 0
else
  i=1
  while IFS= read -r name; do
    printf '%3d) %s\n' "$i" "$name"
    i=$((i + 1))
  done <<<"$choices"
  printf 'Numbers to run, separated by spaces: '
  read -r answer
  picked=""
  for n in $answer; do
    name=$(printf '%s\n' "$choices" | sed -n "${n}p")
    if [ -z "$name" ]; then
      echo "No script number $n" >&2
      exit 1
    fi
    picked="$picked$name"$'\n'
  done
fi

picked=$(printf '%s' "$picked" | sed '/^$/d')
[ -z "$picked" ] && exit 0

if printf '%s\n' "$picked" | grep -qx 'local:stop'; then
  local_stop
  exit 0
fi
if printf '%s\n' "$picked" | grep -qx 'local:start'; then
  local_start
  exit 0
fi

count=$(printf '%s\n' "$picked" | wc -l | tr -d ' ')

if [ "$count" -eq 1 ]; then
  exec bun run "$picked"
fi

if [ "$sequential" = true ]; then
  while IFS= read -r name; do
    echo "==> $name"
    bun run "$name"
  done <<<"$picked"
  exit 0
fi

run_parallel "$picked"
