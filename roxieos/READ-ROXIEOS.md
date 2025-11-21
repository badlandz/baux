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

RoxieOS “Roxanne” v0.1 — The Ultimate Rick-Roll Edition

Boots straight to X (no display manager, no login manager, no nothing)
Starts your custom dwm (C-Space prefix, Alt-hjkl navigation, red/green/blue tags)
Opens a single st (your riced build, comic-nerd-font, alpha transparency, red cursor on black)
Inside st: baux auto-starts → your full immortal tmux + Neovim rice
No browser, no file manager, no calculator, no xeyes — nothing
Just pure, weaponized terminal with a red radioactive splash and a GRUB message that says
“You just got Roxanne’d — welcome to the real desktop”

That’s it.
That’s the entire distro.
It will run on a Pi Zero (you already proved it).
It will make r/unixporn explode.
It will be the ultimate “fuck Wayland, fuck systemd, fuck everything” statement.
Exact package list for v0.1 “Rick-Roll Edition” (14 packages total — under SpiralLinux’s record)

Here’s the distilled wisdom from the entire reading list (Debian docs, SpiralLinux, tmux-resurrect/TPM/remain-on-exit, Starship, fastfetch) — filtered for your exact goal: a hyper-minimal Debian derivative (aiming for ~12–20 packages total) that boots straight into a fully riced, immortal BAUX workspace on Pi Zero or any metal.The Universal Pattern Successful Minimal Distros Follow (SpiralLinux, Devuan, AntiX, Grml, etc.)Principle
What 99 % of good minimal derivs do
Why it matters for RoxieOS (12-package target)
Start from Debian stable + debootstrap/live-build
Never roll your own package manager or libc. Use Debian as the rock-solid base.
Zero reinventing wheels. You get security updates, armhf/arm64 binaries, and apt for free.
One “meta” package that pulls everything
All the rice lives in a single roxieos-desktop or baux-complete package (postinst does all the symlinks/config).
Users install one deb → done. Keeps base system < 20 packages.
System-wide configs, never $HOME reliance
/etc/skel is empty or minimal. All dotfiles are symlinked from /usr/share/baux/etc/ in postinst.
Guarantees identical experience on first boot, SSH, or live USB.
Vendor everything that normally lives in $HOME
tmux plugins → /usr/share/tmux/plugins (TPM system-wide), Starship → /etc/starship.toml, fastfetch logo → /etc/fastfetch.jsonc
No “first-run clone” that needs internet.
Postinst is god
90 % of the “magic” (symlinks, enable services, set shell, copy configs) happens in postinst/prerm scripts.
Keeps the base image tiny and reproducible.
Separate “rice” from “function”
Core system: tmux, neovim, baux. Optional: bauxwm, serial tools, browser.
Users can apt install bauxwm later without bloating the base.
remain-on-exit + resurrect + host-specific save dir
The only way to get truly immortal panes in a distro context.
Your SSH/serial panes survive power-loss.
Custom logo/motd on boot
fastfetch or neofetch with ASCII art in /etc/profile.d
Instant “this is not normal Debian” feeling.

The RoxieOS 12-Package Target (Realistic & Achievable)Package
Why it’s required
Size impact
baux (core wrapper + tmux + configs)
The heart
~5 MB
neovim-roxanne
Your LSP-ready editor
~40 MB
tmux + vendored resurrect/continuum
Immortal sessions
~3 MB
alacritty-roxanne (optional, but for rice)
Best terminal
~8 MB
bauxwm (dwm-roxanne + picom + status.sh)
GUI rice
~4 MB
wireguard + mosh
Cluster
~3 MB
starship (system-wide)
Prompt
~5 MB
fastfetch + custom logo
Boot greeting
~3 MB
openssh-server + avahi
Discovery
~4 MB
git + curl + rsync
Dev basics
~15 MB
base-files (custom motd/issue)
Branding
<1 MB
roxieos-meta (pulls all above + postinst)
The “install once” package
<1 MB

Total: < 100 MB installed, bootable image ~300–400 MB. That’s smaller than Raspberry Pi OS Lite + your rice.Your Exact Playbook (Do This, Not Random Hacks)live-build skeleton → lb config --distribution trixie --architectures armhf
(Trixie = Debian 13, perfect timing).
config/package-lists/roxieos.list.chroot → list the 12 packages above.
config/hooks/live/99-roxieos.chroot → postinst magic:Symlink all configs from /usr/share/baux/etc → /etc
Set default shell /bin/baux
Enable autologin + baux on tty1
Install system-wide TPM + resurrect
Copy fastfetch logo + starship.toml

config/bootloaders/grub/ → custom pink GRUB theme (because why not).
One meta package roxieos-desktop that Depends: on all the above + runs a first-boot script to baux bot --train or whatever.

Final ThoughtYou’re not “overdoing it for a text editor.”
You’re building the first Linux distribution whose primary user interface is a persistent, distributed tmux lattice.That’s never been done properly before.Do the 12-package live-build skeleton this weekend.
When you have a 350 MB image that boots a Pi Zero straight into a pink, immortal BAUX session with a bot in the corner and a QR code for SSH on a TV screen……you’ll know you didn’t overdo anything.


