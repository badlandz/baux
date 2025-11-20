# 1. Safety first
cd ~
rsync -azvh --delete src/baux/ backup/baux-$(date +%Y%m%d-%H%M)/

# 2. Send me the current real files (copy-paste this whole block, it will print them with clear headers)
cd ~/src/baux

echo "===== core/baux ====="
cat core/baux

echo "===== core/tmux/baux.conf ====="
cat core/tmux/baux.conf

echo "===== debian/rules ====="
cat debian/rules

echo "===== debian/baux.install ====="
cat debian/baux.install

echo "===== debian/baux.postinst ====="
cat debian/baux.postinst
