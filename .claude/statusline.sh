#!/bin/bash
# Claude Code status line - Nord theme

input=$(cat)

# Nord palette (24-bit ANSI)
frost_blue='\033[38;2;129;161;193m'
aurora_purple='\033[38;2;180;142;173m'
aurora_green='\033[38;2;163;190;140m'
aurora_yellow='\033[38;2;235;203;139m'
aurora_red='\033[38;2;191;97;106m'
gray_light='\033[38;2;216;222;233m'
reset='\033[0m'

# Parse JSON
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "unknown"')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
cwd=$(echo "$input" | jq -r '.cwd // ""')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Git branch + remote URL for clickable link
branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
remote=$(git -C "$cwd" remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
ahead=$(git -C "$cwd" rev-list --count @{u}..HEAD 2>/dev/null)
behind=$(git -C "$cwd" rev-list --count HEAD..@{u} 2>/dev/null)

# Context icon and colour based on usage (icon and colour thresholds are independent)
if [ "$ctx_pct" -ge 75 ]; then
  ctx_icon="󰡴"
elif [ "$ctx_pct" -ge 50 ]; then
  ctx_icon="󰊚"
elif [ "$ctx_pct" -ge 25 ]; then
  ctx_icon="󰡵"
else
  ctx_icon="󰡳"
fi

if [ "$ctx_pct" -ge 90 ]; then
  ctx_color=$aurora_red
elif [ "$ctx_pct" -ge 50 ]; then
  ctx_color=$aurora_yellow
else
  ctx_color=$aurora_green
fi

# Build output
out="${frost_blue}󱚝  ${gray_light}${model}${reset}"

out+="  ${ctx_color}${ctx_icon}  ${ctx_pct}%${reset}"

if [ -n "$branch" ]; then
  if [ -n "$remote" ] && git -C "$cwd" rev-parse --verify "origin/${branch}" &>/dev/null; then
    branch_link="\e]8;;${remote}/tree/${branch}\a${branch}\e]8;;\a"
  elif [ -n "$remote" ]; then
    branch_link="\e]8;;${remote}\a${branch}\e]8;;\a"
  else
    branch_link="${branch}"
  fi
  out+="  ${aurora_purple}󰘬  ${aurora_purple}${branch_link}${reset}"
  [ "${ahead:-0}" -gt 0 ] && out+=" ${aurora_yellow}󱦲${ahead}${reset}"
  [ "${behind:-0}" -gt 0 ] && out+=" ${aurora_yellow}󱦳${behind}${reset}"
fi

if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
  out+="  ${aurora_green}+${lines_added}${reset} ${aurora_red}-${lines_removed}${reset}"
fi

# Session tokens (only shown when there's been at least one API call)
if [ "$total_in" -gt 0 ] || [ "$total_out" -gt 0 ]; then
  # Format with K suffix for thousands
  fmt_tokens() {
    local n=$1
    if [ "$n" -ge 1000 ]; then
      printf '%.1fk' "$(echo "$n" | awk '{printf "%.1f", $1/1000}')"
    else
      printf '%d' "$n"
    fi
  }
  in_fmt=$(fmt_tokens "$total_in")
  out_fmt=$(fmt_tokens "$total_out")
  out+="  ${aurora_yellow}↓${in_fmt}${reset}${gray_light} ${reset}${aurora_purple}↑${out_fmt}${reset}"
fi

printf '%b\n' "$out"
