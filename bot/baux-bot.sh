#!/usr/bin/env bash
# baux-bot.sh v4.1 — bullet-proof, chat-ready, ARG_MAX-safe
# Drop-in replacement – Nov 19 2025

set -u # removed -e on purpose – we handle errors ourselves
set -o pipefail

BAUX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$BAUX_ROOT/bot/chatlogs"
RAG_DIR="$BAUX_ROOT/bot/rag"
MODEL_PREF=(deepseek-coder:33b llama3.2:3b qwen2.5:7b gemma2:2b phi3:3.8b)

mkdir -p "$LOG_DIR" "$RAG_DIR"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_DIR/current.log"; }

select_model() {
  for m in "${MODEL_PREF[@]}"; do
    if ollama list | grep -q "^${m%%:*}"; then
      echo "$m"
      return
    fi
  done
  echo "llama3.2:1b"
}

# MODEL=$(select_model)
#MODEL="llama3.2b" # Force Fast
MODEL="smollm2:135m" # Force Fast
log "BAUX BOT v4.1 online — using $MODEL — logging to $LOG_DIR"

build_smart_rag() {
  local rag_file="$RAG_DIR/current.txt"
  >"$rag_file"

  if git -C "$BAUX_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    {
      echo "=== GIT STATUS ==="
      git -C "$BAUX_ROOT" status -sb
      echo -e "\n=== LAST 5 COMMITS ==="
      git -C "$BAUX_ROOT" log --oneline -5
      echo -e "\n=== DIFF STAT (last 5 commits) ==="
      git -C "$BAUX_ROOT" diff --stat HEAD~5..HEAD 2>/dev/null || true
    } >>"$rag_file"
  fi

  echo -e "\n=== RECENTLY MODIFIED FILES (sample) ===" >>"$rag_file"
