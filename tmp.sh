# 1. Make sure we are in the REAL repo
cd ~/baux-backup/baux
git pull   # start clean and up-to-date
git status # should say "nothing to commit, working tree clean"

# 2. Create the full structure (idempotent – safe to re-run)
mkdir -p core nvim roxieos forge demo/electronics docs legacy/{coyote,bashrc} roxieos/legacy-ui nvim/legal-fork test

# 3. Copy EVERYTHING from gutted (this is where your real files live)
cp -r ../gutted/coyote/* legacy/coyote/ 2>/dev/null || true
cp -r ../gutted/bashrc/* legacy/bashrc/ 2>/dev/null || true
cp -r ../gutted/sniffer/* demo/electronics/ 2>/dev/null || true
cp -r ../gutted/omarchy/* roxieos/legacy-ui/ 2>/dev/null || true
cp -r ../gutted/nvim-init/* nvim/legal-fork/ 2>/dev/null || true

# 4. Make sure every directory is tracked (Git ignores empty dirs)
touch legacy/coyote/.gitkeep legacy/bashrc/.gitkeep demo/electronics/.gitkeep roxieos/legacy-ui/.gitkeep nvim/legal-fork/.gitkeep

# 5. Create the actual MVP files that ship with BAUX
cat >core/baux <<'EOF'
#!/bin/bash
export BAUX_HOME="/usr/share/baux"
[ -f "$BAUX_HOME/bauxrc" ] && . "$BAUX_HOME/bauxrc"
exec tmux new-session -A -s baux
EOF
chmod +x core/baux

cat >core/bauxrc <<'EOF'
set -o vi
export EDITOR=nvim VISUAL=nvim
if [[ "$TERM" == "linux" ]]; then
    PS1='\[\e[38;5;142m\]\u\[\e[38;5;108m\]@\h \[\e[38;5;180m\]\w \[\e[38;5;142m\]$ \[\e[0m\]'
else
    PS1='\[\e[38;5;142m\]\u\[\e[38;5;108m\]@\h \[\e[38;5;180m\]\w \[\e[38;5;142m\]$ \[\e[0m\]'
fi
alias ls='ls --color=auto' ll='ls -alF' grep='grep --color=auto'
EOF

cat >nvim/init.lua <<'EOF'
vim.g.mapleader = " "
require("lazy").setup({
  "ellisonleao/gruvbox.nvim",
  "ibhagwan/fzf-lua",
})
vim.cmd("colorscheme gruvbox")
EOF

cat >roxieos/os-release <<'EOF'
PRETTY_NAME="RoxieOS Roxanne (Alpha)"
NAME="RoxieOS"
VERSION_ID="roxanne"
ID=roxieos
EOF

cat >demo/electronics/README.md <<'EOF'
Demo: Wi-Fi Sniffer with BAUX
1. Edit in Neovim
2. Compile with arduino-cli
3. Flash via USB
EOF

# 6. Commit and push the REAL content
git add .
git commit -m "Monorepo v0.1 – REAL files, legacy gutted, structure complete"
git push origin main
