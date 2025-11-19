#!/usr/bin/env bash
# baux-bot.sh v4 — RAG-smart, ARG_MAX-proof, model-failover edition
# Drop-in replacement — Nov 19 2025

set -euo pipefail

BAUX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$BAUX_ROOT/bot/chatlogs"
RAG_DIR="$BAUX_ROOT/bot/rag"
MODEL_PREF=(deepseek-coder:33b llama3.2:3b qwen2.5:7b gemma2:2b phi3:3.8b)
MAX_CHUNK_TOKENS=3000
IDLE_DEEP_DIVE=3600 # 1 hour

mkdir -p "$LOG_DIR" "$RAG_DIR"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_DIR/current.log"; }

select_model() {
  for m in "${MODEL_PREF[@]}"; do
    if ollama list | grep -q "^$m "; then
      echo "$m"
      return
    fi
  done
  echo "llama3.2:1b" # ultimate fallback
}

MODEL=$(select_model)
log "BAUX BOT v4 online — using $MODEL — logging to $LOG_DIR"

build_smart_rag() {
  local rag_file="$RAG_DIR/current.txt"
  >"$rag_file"

  # 1. Git status + diff summary (the most important signal)
  if git -C "$BAUX_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "=== GIT STATUS ===" >>"$rag_file"
    git -C "$BAUX_ROOT" status -sb >>"$rag_file" 2>/dev/null || true
    echo -e "\n=== RECENT CHANGES ===" >>"$rag_file"
    git -C "$BAUX_ROOT" diff --stat HEAD~5..HEAD >>"$rag_file" 2>/dev/null || true
    echo -e "\n=== LAST 5 COMMITS ===" >>"$rag_file"
    git -C "$BAUX_ROOT" log --oneline -5 >>"$rag_file" 2>/dev/null || true
  fi

  # 2. Shotgun sampling of key files (random but biased toward recent/changed)
  echo -e "\n=== KEY FILES SAMPLE ===" >>"$rag_file"
  find "$BAUX_ROOT" -type f \( -name "*.conf" -o -name "*.sh" -o -name "*.lua" -o -name "README*" -o -name "*.md" \) \
    -exec stat -c "%Y %n" {} \; 2>/dev/null | sort -nr | head -20 | cut -d' ' -f2- |
    while read -r file; do
      echo -e "\n--- $file ---" >>"$rag_file"
      tail -200 "$file" >>"$rag_file" 2>/dev/null || true
    done

  # 3. Truncate to safe size
  if command -v wc >/dev/null; then
    local lines=$(wc -l <"$rag_file")
    if ((lines > 6000)); then
      tail -5000 "$rag_file" >"$rag_file.truncated"
      mv "$rag_file.truncated" "$rag_file"
    fi
  fi
}

ask_ollama() {
  local prompt="$1"
  local rag_file="$RAG_DIR/current.txt"

  # Feed via stdin — completely ARG_MAX safe
  {
    echo -e "You are BAUX BOT — a helpful, sarcastic, elite embedded systems assistant.\n"
    echo "Current context (repo state + recent files):"
    cat "$rag_file"
    echo -e "\n\nUser: $prompt"
    echo -e "\nAssistant:"
  } | ollama run "$MODEL" --nowordwrap
}

# Initial RAG
build_smart_rag
log "RAG loaded (~$(wc -l <"$RAG_DIR/current.txt") lines)"

last_activity=$(date +%s)
while true; do
  if git -C "$BAUX_ROOT" diff --quiet && (($(date +%s) - last_activity > 300)); then
    sleep 10
    continue
  fi

  log "Change detected — refreshing RAG"
  build_smart_rag
  response=$(ask_ollama "Summarize what just changed and what I should know.")
  echo -e "\nBAUX BOT: $response\n"
  last_activity=$(date +%s)

  # Idle deep dive
  if (($(date +%s) - last_activity > IDLE_DEEP_DIVE)); then
    log "Idle deep dive"
    response=$(ask_ollama "We've been quiet. Give me a deep insight, idea, or refactor suggestion for BAUX/RoxieOS based on current state.")
    echo -e "\nBAUX BOT (deep dive): $response\n"
    last_activity=$(date +%s)
  fi
done
