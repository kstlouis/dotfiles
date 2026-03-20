#!/bin/bash
# Watch ~/.dotfiles and notify when there are uncommitted changes, unpushed commits,
# or commits available to pull. Run manually or install the LaunchAgent to start at login.
#
# INTERVAL: how often to check (default: 3600 = 1 hour)
# DEBOUNCE: min seconds between notifications (default: 7200 = 2 hours)

DOTFILES="${DOTFILES_DIR:-$HOME/.dotfiles}"
INTERVAL="${DOTFILES_WATCH_INTERVAL:-3600}"
DEBOUNCE="${DOTFILES_WATCH_DEBOUNCE:-7200}"
NOTIFY_FILE="$HOME/.dotfiles-watch-last-notify"

cd "$DOTFILES" || exit 1

plural() { [[ "$1" -eq 1 ]] && echo "$2" || echo "${2}s"; }

while true; do
  timeout 10 git fetch --quiet origin 2>/dev/null

  uncommitted=$(git status --porcelain 2>/dev/null)
  ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
  behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)

  parts=()
  [[ -n "$uncommitted" ]] && parts+=("Uncommitted changes")
  [[ -n "$ahead" && "$ahead" -gt 0 ]] && parts+=("$ahead unpushed $(plural "$ahead" commit)")
  [[ -n "$behind" && "$behind" -gt 0 ]] && parts+=("$behind unpulled $(plural "$behind" commit)")

  if (( ${#parts[@]} > 0 )); then
    NOW=$(date +%s)
    LAST_NOTIFY=$(cat "$NOTIFY_FILE" 2>/dev/null || echo 0)
    if (( NOW - LAST_NOTIFY >= DEBOUNCE )); then
      if [[ -z "$uncommitted" && ( -z "$ahead" || "$ahead" -eq 0 ) && "$behind" -gt 0 ]]; then
        msg="Remote is ahead by $behind $(plural "$behind" commit). Pull to update config."
      else
        msg=""
        for part in "${parts[@]}"; do
          [[ -n "$msg" ]] && msg+=", "
          msg+="$part"
        done
        msg+=" in .dotfiles."
      fi
      osascript -e "display notification \"$msg\" with title \"Dotfiles\""
      echo "$NOW" > "$NOTIFY_FILE"
    fi
  fi

  sleep "$INTERVAL"
done
