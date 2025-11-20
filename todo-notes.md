Focusing in on the ssh/sql restore.

Why: I want a couple panes in tmux open always
* connection to proxmox server, btop (or bashtop) all but commands (all in containers):
* postgresql connection to database projects in roxie-data
* remote pi systems collecting data, health/process tracking

How: 

Scan through this conversation to get an idea what the project is again, and then I want to focus in on a discussion of "persistent" connections.
 
BAUX-A <---> BAUX-B
Two systems talking "always alive" sessions (I would like to define terms, to avoid confusion, you may propose clearer, more conventional terms if you can). I am going to call a "session" a single "terminal" connection, one command line interface, telnet, serial, ssh, sql, the "end" could be a port on a server (sql, http, ssh, ftp, etc...) and the other end will be "what to display on the user side."
 
The two systems, BAUX-A and BAUX-B, may have multiple "sessions," such as an sql query window connected directly to the sql server port, an ssh connection to the default user shell, etc.
 
PRESUMING the "default user shell" has been switched to "baux" from bash (or csh, etc), when ssh connects it usually tries to open tmux and load all the neovim/tmux configurations, which it should locally for the user. However, when the user is on BAUX-B and opens ssh connection to BAUX-A (the workstation, now back in the office) from BAUX-B (field rig, laptop) he's in his baux shell and he's initiating a "new pane or window" to open where this connection will live and it will tray to render the baux shell in the pane, nesting tmux and causing issues.
 
This is where the logic "hostname = or != localhost" name becomes key. if hostname != localhost, don't run tmux in baux shell, it's a "run all scripts in baux, except tmux" because we still want all that systems other configs, shell prompt style, etc.
 
But there's a second issue, if baux is the default shell, and the user is logged in on the other system (which they PROBABLY are, it's meant to ALWAYS be running baux), we have a "situation" that's more than just "open a new connection." So, I'm thinking "controlling the connection" is probably better (or in addition to) automatic conflict over-rides. What might be better is this approch:
 
The user can open an ssh connection as normal, must always be there for non-baux connections. Howerver, maybe it would be better to script a menu that can be used when wanted, and that automatically triggers upon connection if it detects the connection is to another baux system.


User enters IP address for BAUX-A from BAUX-B (not sure the keymap, may have to conflict search, but for this example consider "CONTROL-SHIFT-O" for "open") and it "senses" what all the open "sessions" are in the remote baux instence, and presents a choice:

So, from BAUX-B in the feild, it sees BAUX-A and goes:
Switch to BAUX-A (swaps full layout and connections/sessions to BAUX-A)
open "bash"
open "nvim MAKEFILE"
open "btop"
where all the "open" options are pulled from the "open" panes/windows to allow the user to pull just that one open session (pane/window) from the remote BAUX-A into a pane or window on the local system, BAUX-B.

That way, not only do we do conflict resolution, we speed up workflow by not requiring new sessions to be opened and closed all the time, we just move where they are displayed around from one BAUX layout on one system (here BAUX-B) independently of the window in on the remote system (here BAUX-A).

So, in a sense, we have to allow the "session" to stream to two diffrent incidence of TMUX at the same time, and then we've not only solved the "keep connection alive" problem with the session on one side, both sides are taken care of? 




 


Other things to monitor:

What Exists in the tmux ecosystem (2025 reality check)Project
Size
Philosophy
Verdict for BAUX
tmuxp
heavy
YAML session files
wrong direction — we want live resilience, not static sessions
oh-my-tmux
2016
huge, many plugins
dead, unmaintained, git-heavy
gpakosz/.tmux
~2k LOC
very popular, sensible defaults
closest thing to “LunarVim of tmux” — but still pulls TPM
wfxr/tmux-power
medium
theme-focused
nice, but still depends on TPM
tmux-thumbs / resurrect / continuum
gold
the only plugins actually worth it
we do want these features, but not the manager


