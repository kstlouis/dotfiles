#!/bin/bash
# Watch ~/.dotfiles and notify when there are uncommitted changes.
# Run manually or install the LaunchAgent to start at login.
#
# INTERVAL: how often to check (default: 3600 = 1 hour)
# DEBOUNCE: min seconds between notifications (default: 21600 = 6 hours; at most a few per day)

DOTFILES="${DOTFILES_DIR:-$HOME/.dotfiles}"
INTERVAL="${DOTFILES_WATCH_INTERVAL:-3600}"
DEBOUNCE="${DOTFILES_WATCH_DEBOUNCE:-21600}"
LAST_NOTIFY=0

cd "$DOTFILES" || exit 1

while true; do
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    NOW=$(date +%s)
    if (( NOW - LAST_NOTIFY >= DEBOUNCE )); then
      osascript -e "display notification \"You've got uncommitted changes in .dotfiles!\" with title \"Dotfiles\""
      LAST_NOTIFY=$NOW
    fi
  fi
  sleep "$INTERVAL"
done
