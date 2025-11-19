# 1. Make sure the prefix is explicitly set (add near the top of the config)
sed -i '/set -g history-limit/a \
set -g prefix C-Space\
unbind C-b\
bind C-Space send-prefix\
' core/tmux/baux.conf

# 2. Double-check the entrypoint is using the correct path
cat >core/baux <<'EOF'
#!/bin/bash
export BAUX_HOME="/usr/share/baux"
export NVIM_INIT="$BAUX_HOME/nvim/init.lua"
TMUX_CONF="$BAUX_HOME/tmux/baux.conf"
exec tmux -f "$TMUX_CONF" new-session -A -s "baux-#H"
EOF
chmod +x core/baux
