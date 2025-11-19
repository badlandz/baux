# 1. Remove the broken half-created directories
rm -rf core/tmux/plugins

# 2. Create the real, simple tmux layout (no plugins yet — we add them later)
mkdir -p core/tmux

# core/tmux/baux.conf — main config
cat >core/tmux/baux.conf <<'EOF'
# BAUX tmux master config v0.2.1 — no external deps, works everywhere
set -g prefix C-a
unbind C-b
bind C-a send-prefix

set -g history-limit 50000
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g escape-time 0
set -g status-interval 5
set -g status on
set -g status-position top

# Left: BAUX on hostname
set -g status-left "#[fg=cyan,bold] BAUX on #H #[default] "

# Window list (center)
setw -g window-status-format " #I:#W#{?window_activity_flag,*, } "
setw -g window-status-current-format " #I:#W#{?window_zoomed_flag,Z,}* "
setw -g window-status-current-style fg=brightwhite,bold
setw -g window-status-style fg=cyan

# Right: battery (only when on battery) + day + time
set -g status-right "#[fg=yellow]#{?battery_percentage,#{battery_percentage}%% ,}#(date '+%a %H:%M')"

# Detect truecolor → go full bling
if-shell 'test -n "$COLORTERM" || echo "$TERM" | grep -q "256color\|24bit"' {
    set -g status-style bg=#1e1e2e,fg=#cdd6f4
    set -g status-left "#[fg=#1e1e2e,bg=#f5c2e7,bold] BAUX on #H #[default] "
    setw -g window-status-current-style bg=#89b4fa,fg=#1e1e2e,bold
    set -g status-right "#[fg=#a6e3a1]#{?battery_percentage,#{battery_percentage}%% ,}#(date '+%a %H:%M')"
}

# User overrides last
if-shell '[ -f /etc/baux/tmux.local.conf ]' 'source-file /etc/baux/tmux.local.conf'
EOF

# 3. Update the entrypoint to use the new config
cat >core/baux <<'EOF'
#!/bin/bash
export BAUX_HOME="/usr/share/baux"
export NVIM_INIT="$BAUX_HOME/nvim/init.lua"
exec tmux -f "$BAUX_HOME/tmux/baux.conf" new-session -A -s baux
EOF
chmod +x core/baux

# 4. Fix debian/baux.install — remove old broken lines, add correct ones
# First remove any old tmux lines
sed -i '/bauxrc/d' debian/baux.install
sed -i '/tmux/d' debian/baux.install

# Add the correct new ones
echo "core/tmux/baux.conf       /usr/share/baux/tmux/" >>debian/baux.install
echo "core/baux                 /usr/bin/" >>debian/baux.install

# 5. Make sure postinst exists and creates the override file
cat >debian/postinst <<'EOF'
#!/bin/sh
set -e
mkdir -p /etc/baux
[ -f /etc/baux/tmux.local.conf ] || cat > /etc/baux/tmux.local.conf <<'LOCAL'
# BAUX user-local tmux overrides — safe to edit
# This file is sourced last by /usr/share/baux/tmux/baux.conf
LOCAL
exit 0
EOF
chmod +x debian/postinst
