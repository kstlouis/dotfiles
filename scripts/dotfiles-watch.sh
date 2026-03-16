#!/bin/bash
# Watch ~/.dotfiles and notify when there are uncommitted changes or unpushed commits.
# Run manually or install the LaunchAgent to start at login.
#
# INTERVAL: how often to check (default: 3600 = 1 hour)
# DEBOUNCE: min seconds between notifications (default: 7200 = 2 hours)

DOTFILES="${DOTFILES_DIR:-$HOME/.dotfiles}"
INTERVAL="${DOTFILES_WATCH_INTERVAL:-3600}"
DEBOUNCE="${DOTFILES_WATCH_DEBOUNCE:-7200}"
LAST_NOTIFY=0

cd "$DOTFILES" || exit 1

while true; do
  uncommitted=$(git status --porcelain 2>/dev/null)
  ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)

  uncommitted_yes=0
  unpushed_yes=0

  [[ -n "$uncommitted" ]] && uncommitted_yes=1
  [[ -n "$ahead" && "$ahead" -gt 0 ]] && unpushed_yes=1

  if (( uncommitted_yes || unpushed_yes )); then
    NOW=$(date +%s)
    if (( NOW - LAST_NOTIFY >= DEBOUNCE )); then
      if (( uncommitted_yes && unpushed_yes )); then
        [[ "$ahead" -eq 1 ]] && c="commit" || c="commits"
        msg="Uncommitted changes and $ahead unpushed $c in .dotfiles"
      elif (( uncommitted_yes )); then
        msg="Uncommitted changes in .dotfiles"
      else
        [[ "$ahead" -eq 1 ]] && c="commit" || c="commits"
        msg="$ahead unpushed $c in .dotfiles"
      fi
      osascript -e "display notification \"$msg\" with title \"Dotfiles\""
      LAST_NOTIFY=$NOW
    fi
  fi
  sleep "$INTERVAL"
done
