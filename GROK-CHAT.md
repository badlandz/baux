# The Read Me

It is a good time to PAUSE our progress here, and try to rewrite a condensed project summary, with as many referances and ideas as we can find that "fit" the goal and communicate the message of the project. So, here is my long winded attempt to define the project, please help write a more condensed, highly informative, well referanced project summary that makes the goals, plans, use, reason, structure, strategy, and everything "fit together" better for a more complete and coherent picture of this project.

This is "baux" development, the shell to replace bash, that's a "full ui" shell, like an "os" for a terminal. It's part of roxieos, so we need to define the parts more clearly.

It is time to reflect on the status of the project, and the goals.

The status of the project right now is an "idea" (coyoteUI) that is "somewhat working" in parts on github. It was "so bloated" it will not compile easily on a Raspberry Pi, so it was decided to develop a "static binary" that included as much of this as possible, but simplified where possible, making packages by building repo server (container 901 on a proxmox server), a development container (902 just for testing, destroy and recreate clean for "fresh install" testing), and a package that installs the "baux"" UI on "roxieos" development system. "roxieos" will be a micro distribution of debian, tracking it, and "roxanne" will be the release that matches "trixie" in the fork, forking debian like mint linux forked ubuntu, like MX Linux and Kali Linux are based on Debian, only for this specific "small fast" full "developer IDE" for small electronics, with no x or wayland, all run in a terminal or on console.

On the developer container (902) I have added a user who has added the full installation from https://github.com/badlandz/coyoteUI to the user account "coyote" on roxieos-dev container (902). This is to compare "full bling" the way I am using my system now, with the status of this "tiny static build."  I know full bling won't compile in even a day on a rasberry pi zero 2w, I've been waiting. So, now I'm thinking "how small should it be, and how much bling can we pack in if it's a static binary?

The GOAL is a "micro" installation, targeted somewhere "above" Alpine Linux and Tiny Core Linux. But, only as much as needed to keep Debian Trixie compatibility for deployment of things like full GUI desktops (WAY outside the scope of this, but needs to run on same system I run my GUI 3d printer software on, so Debian compatible), and other common development environments special to that sort of use, such as the arduino IDE, and think about what and which may be easier to co-exist with if we stay within the Debian eco-system. 

This raises the question of the "busybox" approach used in tiny distros, combining multiple tools into a small binary package for deployment. If we "focus" this on it's purpose, we can select all the right tools, and then cross index which will be able to merge/build together more efficiently. Can it be "tightened" by merging binaries/libraries like busy box, and/or hard code in some of the plugins, configurations, and themes, to save size, improve speed (giving up on some configuration options, which, why, when?)

So, again, the goal:

FULL bling IDE "in a terminal or on console" with NO X, wayland, etc.

It will be used for arduino sensors and data collection, so, programming languages are usually python, c, arduino code, sql, lua, bash, and not much else. We may want to see "how much coverage" the LSPs for neovim are going to eat up, and how tiny we can make this, but still usable. Let's stay focused on "we at least want lua and neovim" for NOW, maybe "someday" a "micro version" using vim, vi, or smaller editor. For now key features:

1) Neovim
2) Tmux

And the best configuration scripts we can come up with for "get into this system, change code, re-test this thing and see if the sensor is reading" feild use of the system, and rebranding, and workflow.

# BAUX is "distributed" session multiplexer

ALSO, baux, the interface build on neovim and tmux, it should be a "distributed cross operating system interface" not a roxieos interface. Understand, we have the plugins to keep sessions alive in tmux, roll back open to the previous status after hardware crash, and we are going to be ssh'ed all over the place, from one system to another, tweaking some code. SO, DISTRIBUTED interface isn't that hard, in theory. What each pane, window, "session", has going on could be an ssh connection. We need to work in ssh key integration so those sessions automatically try to reconnect/reopen and go live again.

Consider a workflow, programming and configuring parts like an EspoTek Labrador, RepRapDiscount Full Graphic Smart Controller, 1602A LCD, SD card reader/writer modules with SPI interface, a handful of SSD1306 oled displays for data readings, and a 2-Channel 5V Relay Module are included in a custom electronics enclosure. In this workflow, there will be code edited, and possibly compiled on a "remote" server/workstation (cross compile for arduino or pi target) due to the "system" being mostly microcontrollers, and the "interface" could be a temporary laptop connection, so compiling might be done by logging into the server through our custom "baux session" to compile, then transfer and burn onto an SD card or flashed direction 

This is similar to the sql issue. You somewhat need to "configure" your servers for sql, and sessions in a pane/window. So, basically, with all these sessions "configured" for you with your built in configurator, your going to have servers, databases, diffrent sessions all over the place.

This does create a master/slave problem, I think should be bipassed by "layouts" where the "baux session" you are in is for @host your on, if @host = localhost, then force "baux @host layout." Otherwise, "baux" can be aware "not @localhost" in a "open tty/connection" and put it where that connection belongs in the multiplexer layout for "baux @host layout" on your localhost.  I think that makes sense?

Each host has it's own layout, if it's localhost, it applies, if it's not, it's probably in someone's @locahost layout being displayed, so don't try to put tmux into a tmux frame, it won't end well, it can cascade and be a huge issue. so just define layouts for each host (hostname = localhost true/false).

Right now, chatting with grok, next question for him will be:

That goes:
https://grok.com/c/0e223945-b9da-49d8-8a21-3865e5a69967
once my time resets. But that's pretty cool we have a debian package building repo for baux now.


There are some intereting projects to consider, in addition to adapting some of raspberry pi OS like the configuration utility.

Key Components for Arduino in Neovim can include clang arduino-cli: arduino-language-server: Neovim LSP Configuration (nvim-lspconfig): Syntax Highlighting and Indentationm, plugins vim-Arduino-syntax, yuukiflow/Arduino-Nvim, telescope.nvim: Used in conjunction with Arduino-Nvim for features like advanced library management and visual indicators for installed libraries.

Also think about flashing, uploading, burning images (why caligula was there to be prettier than dd), consider other PlatformIO Integration, PlatformIO Core, nvim-platformio (or vim-pio), nvim-dap, nvim-dap-ui, Serial Monitor, nvim-platformio PioMonitor.



