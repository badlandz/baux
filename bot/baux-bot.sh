#!/usr/bin/env bash
# ~/src/baux/bot/baux-bot.sh  ← rename it exactly this, it’s canon now
set -euo pipefail

REPO="$HOME/src/baux"
WATCHER="qwen2.5-coder:7b"
BIG_BRAIN="deepseek-coder:33b"
MIN_GAP=$((5 * 60))

clear
echo -e "\033[38;5;208mBAUX BOT online — watching $REPO\033[0m"
echo -e "\033[38;5;150mI only speak when it matters. Type anything + Enter to ask me directly.\033[0m\n"

# Background daemon that never blocks the pane
watch_loop() {
  local last_hash="" last_spoke=0
  while true; do
    hash=$(find "$REPO" -type f \( -name "*.lua" -o -name "*.sh" -o -name "*.md" \) -exec sha256sum {} + 2>/dev/null | sha256sum | cut -d' ' -f1)
    now=$(date +%s)
    [[ "$hash" == "$last_hash" ]] || [[ $((now - last_spoke)) -lt $MIN_GAP ]] && {
      sleep 45
      continue
    }

    diff=$(git -C "$REPO" diff --patience --unified=8 2>/dev/null || echo "no git")
    prompt="BAUX just changed. Diff:\n$diff\n\nOne brutally honest sentence about what just happened and whether it will work on Pi Zero. Empty response = nothing worth saying."

    # Fire-and-forget to background ollama jobs so pane stays responsive
    {
      response=$(echo "$prompt" | ollama run "$WATCHER" 2>/dev/null || true)
      if echo "$response" | grep -iqE "risk|break|danger|careful|no|won't"; then
        response=$(echo "$prompt\nPrevious: $response\nDeep dive with 33B." | ollama run "$BIG_BRAIN" 2>/dev/null || true)
      fi
      [[ -n "$response" ]] && echo -e "\033[38;5;150mBAUX BOT:\033[0m $response\n"
    } &>/dev/null &

    last_hash="$hash" last_spoke="$now"
    sleep $((RANDOM % 90 + 30))
  done
}

# Start background watcher
watch_loop &

# Interactive foreground — you can type questions any time
while true; do
  read -p $'\033[38;5;220m> \033[0m' question
  [[ -z "$question" ]] && continue
  echo -e "\033[38;5;203mBAUX BOT (33B):\033[0m"
  ollama run "$BIG_BRAIN" "$question"
  echo
done
