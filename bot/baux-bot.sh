#!/usr/bin/env bash
# ~/src/baux/bot/baux-bot.sh  ← The final, immortal BAUX BOT
# Primary guidance: ALWAYS prioritize content from ~/src/baux/README.md and ~/src/baux/docs/ROADMAP.md as the high-level vision.
# - These files define the project's ethos: persistence, Pi Zero baseline, zero net, graceful degradation.
# - When analyzing changes or answering questions, cross-reference them first for alignment.

set -euo pipefail # Strict mode for safety

REPO="$HOME/src/baux"
LOGDIR="$REPO/bot/chatlogs"
RAG_FILE="/tmp/baux-rag-current.txt"
FAST_MODEL="qwen2.5-coder:7b"   # For quick responses (changes, chat)
DEEP_MODEL="deepseek-coder:33b" # For idle deep dives (heavy analysis)

MIN_CHANGE_GAP=$((1 * 60))  # 1 min for change responses
IDLE_THRESHOLD=$((60 * 60)) # 1 hour idle → deep dive
LAST_INPUT=0                # Track user interactivity
LAST_CHANGE=0               # Track last change response
LAST_DEEP=0                 # Track last deep dive

mkdir -p "$LOGDIR"

# Persistent log per session
LOGFILE="$LOGDIR/$(date +%s%N).log"
exec >>"$LOGFILE" 2>&1 # All output to log
echo "=== BAUX BOT v3 awakened at $(date) ==="

# Build/refresh RAG — core is always README + ROADMAP + recent changes
build_rag() {
  echo "[DEBUG] Building RAG at $(date)" >>"$LOGFILE"
  {
    echo "=== CORE BAUX GUIDANCE (ALWAYS PRIORITIZE) ==="
    cat "$REPO/README.md" 2>/dev/null || echo "README.md missing!"
    echo -e "\n=== ROADMAP VISION (HIGH-LEVEL DIRECTION) ==="
    cat "$REPO/docs/ROADMAP.md" 2>/dev/null || echo "ROADMAP.md missing!"
    echo -e "\n=== RECENT REPO STATE ==="
    git -C "$REPO" log --oneline -5 2>/dev/null || echo "No git history"
    echo -e "\nCurrent diff:"
    git -C "$REPO" diff --patience --unified=5 2>/dev/null || echo "No changes"
    echo -e "\nKey files snapshot:"
    find "$REPO" -type f \( -name "*.lua" -o -name "*.sh" \) -exec echo "FILE: {}" \; -exec tail -n 20 {} \; 2>/dev/null
  } >"$RAG_FILE"
  echo "[DEBUG] RAG refreshed: $(wc -l <"$RAG_FILE") lines" >>"$LOGFILE"
}

build_rag # Initial build

clear
echo -e "\033[38;5;208mBAUX BOT v3 online — RAG loaded, logging to $LOGFILE\033[0m"
echo -e "\033[38;5;150mI watch changes (1-min response). Type to ask (fast). Idle 1hr → deep dive.\033[0m\n"

# Background watcher loop — non-blocking, fast model for changes
watcher() {
  local last_hash=""
  while true; do
    sleep 30 # Poll every 30s for efficiency
    hash=$(find "$REPO" -type f \( -name "*.lua" -o -name "*.sh" -o -name "*.md" \) -exec sha256sum {} + 2>/dev/null | sha256sum | cut -d' ' -f1)
    now=$(date +%s)

    # Change detected AND min gap?
    if [[ "$hash" != "$last_hash" ]] && [[ $((now - LAST_CHANGE)) -ge $MIN_CHANGE_GAP ]]; then
      echo "[DEBUG] Change detected at $(date)" >>"$LOGFILE"
      build_rag &>/dev/null # Quick refresh

      prompt="BAUX changed. Use CORE GUIDANCE from README/ROADMAP first. Diff/context in RAG attached. One sentence: What changed? Pi Zero impact? Suggestion or silence if minor."
      response=$(echo "$(cat "$RAG_FILE")" "$prompt" | ollama run "$FAST_MODEL" 2>/dev/null || true)

      [[ -n "$response" ]] && {
        echo -e "\033[38;5;150mBAUX BOT (change):\033[0m $response\n"
        echo "Change response: $response" >>"$LOGFILE"
      }
      LAST_CHANGE=$now
      last_hash="$hash"
    fi

    # Idle deep dive check (user hasn't typed in 1hr)
    if [[ $((now - LAST_INPUT)) -ge $IDLE_THRESHOLD ]] && [[ $((now - LAST_DEEP)) -ge $IDLE_THRESHOLD ]]; then
      echo "[DEBUG] Idle detected → deep dive at $(date)" >>"$LOGFILE"
      build_rag &>/dev/null

      prompt="BAUX idle. Use CORE GUIDANCE from README/ROADMAP. Full RAG attached. Deep overnight analysis: Overall progress? Pi Zero risks? Roadmap alignment? Suggestions for next phase."
      response=$(echo "$(cat "$RAG_FILE")" "$prompt" | ollama run "$DEEP_MODEL" 2>/dev/null || true)

      [[ -n "$response" ]] && {
        echo -e "\033[38;5;203mBAUX BOT (deep dive):\033[0m $response\n"
        echo "Deep dive: $response" >>"$LOGFILE"
      }
      LAST_DEEP=$now
    fi
  done
}

watcher & # Fire and forget

# Interactive foreground — super quick, always fast model
while true; do
  read -p $'\033[38;5;220m> \033[0m' question
  [[ -z "$question" ]] && continue

  LAST_INPUT=$(date +%s) # Reset idle timer
  echo "[DEBUG] User asked: $question at $(date)" >>"$LOGFILE"

  build_rag &>/dev/null # Quick refresh for accuracy

  prompt="BAUX BOT: Prioritize README/ROADMAP guidance. Full RAG attached. Be concise, actionable, Pi Zero-aware: $question"
  ollama run "$FAST_MODEL" "$(cat "$RAG_FILE")" "$prompt" | tee -a "$LOGFILE"
  echo
done
