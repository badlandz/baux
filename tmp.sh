# 1. Backup current (just in case)
cp core/bauxrc core/bauxrc.backup
cp core/baux core/baux.backup

# 2. Rewrite tmux/baux.conf (the new heart — full CoyoteUI-inspired)
cat >core/tmux/baux.conf <<'EOF'
# BAUX tmux config v0.2.2 — CoyoteUI-inspired, host-aware, resilient
# Prefix: C-Space (ergonomic, low-finger stretch)

# Global settings
set -g history-limit 50000
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g detach-on-destroy off
set -g escape-time 0
set -g status-interval 5
set -g status on
set -g status-position top
set -g status-justify left

# Prefix setup
set -g prefix C-Space
unbind C-b
bind C-Space send-prefix

# CoyoteUI-style navigation (no prefix needed — fast pane moves)
bind -n M-h select-pane -L
bind -n M-j select-pane -D
bind -n M-k select-pane -U
bind -n M-l select-pane -R

# Resize panes (hold Alt + arrow or hjkl)
bind -n M-H resize-pane -L 5
bind -n M-J resize-pane -D 5
bind -n M-K resize-pane -U 5
bind -n M-L resize-pane -R 5

# Splits (CoyoteUI: Alt for quick splits, path-aware)
bind -n M-% split-window -h -c "#{pane_current_path}"
bind -n M-" split-window -v -c "#{pane_current_path}"
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Windows (prefix for create/rename, Alt-1/2/3 jump)
bind c new-window -c "#{pane_current_path}"
bind , command-prompt -I "#W" "rename-window '%%'"
bind . command-prompt -I "#S" "rename-session '%%'"
bind 1 select-window -t 1
bind 2 select-window -t 2
bind 3 select-window -t 3
bind 4 select-window -t 4
bind 5 select-window -t 5

# Reload config
bind r source-file "#{file}" \; display "BAUX reloaded!"

# Status bar — our exact design
set -g status-style bg=default,fg=colour250
set -g status-left "#[fg=black,bg=cyan,bold] BAUX #[fg=cyan,bg=default,nobold] on #H #[default]  "
set -g status-right "#[fg=yellow]#{?client_prefix,#[bg=red]PREFIX#[default] ,}#[fg=green]%a %H:%M"

# Window list (center, activity-aware)
setw -g window-status-format " #I:#W#{?window_activity_flag,#[fg=yellow](!),} "
setw -g window-status-current-format " #I:#W "
setw -g window-status-current-style fg=brightwhite,bold
setw -g window-status-activity-style fg=yellow

# Center: active pane path (smart truncate)
set -g status-justify centre
setw -g window-status-format " #I:#W "
setw -g window-status-current-format " #I:#W "
set -g status-center "#[fg=brightwhite,bold]#{b:pane_current_path}#[default]"

# Bling mode (truecolor/256 + nerd fonts)
if-shell 'test -n "$COLORTERM" || echo "$TERM" | grep -q "256color\|24bit"' '\
    set -g status-style bg=#1e1e2e,fg=#cdd6f4; \
    set -g status-left "#[fg=#1e1e2e,bg=#89b4fa,bold] BAUX #[fg=#89b4fa,bg=#1e1e2e,nobold] on #H #[default]  "; \
    setw -g window-status-current-style bg=#89b4fa,fg=#1e1e2e,bold; \
    set -g status-right "#[fg=#a6e3a1]%a %H:%M"; \
    set -g status-center "#[fg=#f9e2af,bold]#{b:pane_current_path}#[default]" \
'

# Battery only on battery (tiny script — add to core/scripts if needed)
set -g status-right "#(test -f /sys/class/power_supply/BAT*/capacity && cat /sys/class/power_supply/BAT*/capacity || echo '')% #[fg=green]%a %H:%M"

# Future: resurrect/continuum hooks (placeholders)
set -g @resurrect-strategy-nvim 'session'
set -g @continuum-restore 'on'

# User overrides last
if-shell '[ -f /etc/baux/tmux.local.conf ]' 'source-file /etc/baux/tmux.local.conf'
EOF

# 3. Update entrypoint (host-specific session, NVIM integration)
cat >core/baux <<'EOF'
#!/bin/bash
export BAUX_HOME="/usr/share/baux"
export NVIM_INIT="$BAUX_HOME/nvim/init.lua"
TMUX_CONF="$BAUX_HOME/tmux/baux.conf"
SESSION="baux-$(hostname)"
exec tmux -f "$TMUX_CONF" new-session -A -s "$SESSION"
EOF
chmod +x core/baux

# 4. Clean up old bauxrc (no longer needed — we're on tmux/baux.conf now)
rm -f core/bauxrc

# 5. Update debian/baux.install (point to new config, remove old)
sed -i '/bauxrc/d' debian/baux.install
sed -i '/tmux\/baux.conf/d' debian/baux.install # avoid dupes
echo "core/tmux/baux.conf    /usr/share/baux/tmux/" >>debian/baux.install
echo "core/baux              /usr/bin/" >>debian/baux.install

# 6. Ensure postinst creates overrides
cat >debian/postinst <<'EOF'
#!/bin/sh
set -e
mkdir -p /etc/baux
[ -f /etc/baux/tmux.local.conf ] || cat > /etc/baux/tmux.local.conf <<'LOCAL'
# BAUX user-local tmux overrides — add custom binds here
# Example: bind-key -n M-q detach-client
LOCAL
exit 0
EOF
chmod +x debian/postinst
