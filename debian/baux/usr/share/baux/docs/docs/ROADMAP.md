# BAUX / RoxieOS Roadmap — November 2025 Edition

What we now know is real:
- A single .deb turns any Debian box into a persistent, beautiful, CoyoteUI-powered workspace.
- It runs perfectly on a Pi Zero W (512 MB RAM, console, wireless).
- Host-named sessions + SSH already give us “remote screen” super-powers.
  - install raspberry pi os minimal on pi zero w, install baux package then:
    - run '''echo "baux" >> .bashrc''' and set autologin console in rappi-config
- We finally have momentum.

What's missing still:
- true "stay alive" ssh/sql sessions with servers in panes:
  = there are "standards" to be droped into place for the config
- hostname layout distinction, and conflict resolution (don't run baux in baux, if ssh then test "already in baux"
   NOTE:
     I have worked out a plan, need to implement, "connection" is not localhost, or tmux running "detach" remote tmux before opening ssh session... etc...
- The screen saver routines, to keep screen burn and auto kiosk mode stolen from stuff like hollywood
- scripted rebuilds of the actual .deb that does all this, from within this... LOL

SHORT TERM OBJECTIVES:
- Automate the build of the debian package for baux:
  - script the sync with the repo, merges, management of the code of baux itself
  - script the build itself to dump the .deb where it should be in the repo:
  NOTE: script (build box lua script tmux/neovim, global?) '''debuild -us -uc -b''' to output in '''$HOME/src/baux/packages/''' see: pct 901 baux-forge


Everything below is ordered by **impact / joy / feasibility**.

## Phase 0 – “It Never Dies” (December 2025 – 2–4 weeks)
Make BAUX survive power cycles and disconnects — the single feature that turns “cool config” into “I can’t live without this”.

- Vendor tmux-resurrect + continuum (host-specific save paths using `#H`)
- Auto-save every 5–15 min, restore on attach
- Auto-reconnect SSH panes on restore
- First-run default layout:  
  `nvim left 70% | shell bottom-right | serial tail top-right`
- `baux --new` forces a fresh session (escape hatch)

**Milestone**: You can kill -9 tmux, unplug the Pi, plug it back in days later → everything is exactly where you left it.

## Phase 1 – “It Feels Like Home” (January 2026)
Polish + unification so the first 10 seconds feel curated and professional.

- Final status bar polish (badge spacing, battery, center path, activity bells)
- Unified BAUX menu (Prefix-? or F12) — single ncurses/Lua binary that replaces:
  - tmux command prompt
  - raspi-config
  - nvim :options equivalent
  - future package installer
- Screensaver / Kiosk mode (the hollywood flex)
  - Idle 5 min → source `/usr/share/baux/screensaver.conf`
  - Cycles btop, cmatrix, hollywood, system info, QR code for SSH, optional todo/weather pane
  - Any key → instant return to normal layout
  - Boot-to-screensaver if no keyboard detected (perfect for wall TVs)

**Milestone**: You plug a Pi into a TV, it boots, shows a badass animated dashboard with your IP as QR code. Someone scans it with their phone → instant SSH into your workspace.

## Phase 2 – “It’s an Actual OS” (February–March 2026)
RoxieOS becomes real and reproducible.

- `roxieos-builder` script → one-command minimal image
  - debootstrap + chroot
  - baux as login shell
  - auto-login console + screensaver mode
  - optional packages menu at first boot
- Optional packages (installed via BAUX menu)
  - w3m or browsh (themed, vim bindings, opens in new pane)
  - dashboard widgets (todo, weather, SQL tail, MQTT monitor)
  - platformio / arduino-cli toolchains
- Host-specific config sync (optional)
  - Small daemon that rsyncs `/etc/baux/local.conf` from a central git repo or USB stick

**Milestone**: You can dd a 300–500 MB image to an SD card → boot → have a complete embedded cyberdeck OS that feels like it was custom-made for you.

## Phase 3 – “The Static Dream” (2026–2027, v1.0)
The final form.

- Single static `baux` mega-binary (busybox-style)
  - Contains patched tmux + neovim + bash + lua + all plugins
  - No system tmux/neovim needed
  - < 30 MB total
- RoxieOS “Roxanne” release — official image with static baux as `/bin/sh`
- Multi-host lattice orchestration
  - Prefix-L → “open pane on remote host X”
  - Shared clipboard, shared search, shared layout propagation

## Dead Ideas Graveyard (we tried, they’re gone)
- TPM or any git-based plugin manager
- YAML session files (tmuxp/tmuxinator)
- Separate CoyotUI repo (it’s now fully merged into BAUX)
- Anything that phones home on first run

## Guiding Principles (never break these)
- Zero internet required after install
- Works on Pi Zero W (512 MB, console, 16 colors)
- Graceful degradation everywhere
- Hostname is sacred (it is the namespace)
- One .deb / one image should feel like a complete OS

We are no longer asking “will this work?”.  
We are now asking “how fast can we make it legendary?”.

Current version: **v0.2.3** — “It’s beautiful and distributable”  
Next target: **v0.3 “Immortal”** — resurrect + screensaver (January 2026)

— badlandz, November 19 2025
