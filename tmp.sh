# 1. Replace rules
cat >debian/rules <<'EOF'
#!/usr/bin/make -f
%:
	dh $@

override_dh_auto_install:
	mkdir -p $(CURDIR)/debian/baux/usr/bin
	mkdir -p $(CURDIR)/debian/baux/usr/share/baux
	mkdir -p $(CURDIR)/debian/baux/usr/share/tmux-plugins

	install -m 0755 core/baux $(CURDIR)/debian/baux/usr/bin/baux

	cp -a nvim demo docs forge legacy roxieos test core/tmux $(CURDIR)/debian/baux/usr/share/baux/

	if [ ! -d "$(CURDIR)/debian/baux/usr/share/tmux-plugins/resurrect" ]; then
	    git clone -q https://github.com/tmux-plugins/tmux-resurrect \
	        $(CURDIR)/debian/baux/usr/share/tmux-plugins/resurrect || true
	fi
	if [ ! -d "$(CURDIR)/debian/baux/usr/share/tmux-plugins/continuum" ]; then
	    git clone -q https://github.com/tmux-plugins/tmux-continuum \
	        $(CURDIR)/debian/baux/usr/share/tmux-plugins/continuum || true
	fi
EOF

# 2. Make executable
chmod +x debian/rules

# 3. BUILD — THIS ONE WILL WORK
debuild -b -uc -us
