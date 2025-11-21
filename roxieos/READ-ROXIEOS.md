Linked here are the RoxieOS plans, and here in this document are some notes of guidance:

Reading List — Zero to RoxieOS (November 20 2025 edition)Debian changelog format – https://www.debian.org/doc/manuals/maint-guide/dreq.en.html#changelog
Debian Derivatives Guidelines – https://wiki.debian.org/Derivatives/Guidelines
live-build manual – https://live-team.pages.debian.net/live-manual/
SpiralLinux build scripts – https://github.com/SpiralLinux/SpiralLinux-project
tmux-resurrect docs – https://github.com/tmux-plugins/tmux-resurrect/blob/master/README.md
TPM system-wide install – https://github.com/tmux-plugins/tpm/blob/master/docs/tpm_not_in_home.md
remain-on-exit explanation – https://man.openbsd.org/tmux#remain-on-exit
Starship system-wide config – https://starship.rs/advanced-config/#system-wide-installation
Debian package naming – https://www.debian.org/doc/manuals/maint-guide/dother.en.html#naming
fastfetch custom logos – https://github.com/fastfetch-cli/fastfetch/wiki/Custom-logo

# RoxieOS “Roxanne” v0.1 — The Rick-Roll Edition

8 packages. < 400 MB. Boots straight to immortal BAUX in a red desert hellscape.

- roxieos-base → skeleton + autologin + X start
- baux → your immortal tmux/neovim + all configs (starship.toml, btop.theme, fastfetch.jsonc, motd, etc.)
- bauxwm → dwm-roxanne + st-roxanne + alacritty-roxanne + xinitrc
- neovim-roxanne → your full LSP monster
- plymouth + theme → red radioactive boot splash
- grub + theme → “You just got Roxanne’d”
- fastfetch/btop/starship → pulled in by baux, themed via files
- roxieos-meta → one package that Depends: on all above + postinst does the symlinks

That’s it.

No custom kernel needed (just symlink /boot/vmlinuz → vmlinuz-roxanne in postinst).
No 50 config packages.

One `lb build` → ISO that boots a Pi Zero straight into a pink cyberdeck that never forgets where you were.

This is the distro that makes people say  
“wait, that’s allowed?”


