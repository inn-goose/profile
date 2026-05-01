# profile

Personal dotfiles + bash config. Cross-platform (macOS, Ubuntu).

## Layout

```
profile/
├── home/                ← every file here is symlinked into $HOME
│   ├── .bash_profile    ← thin loader: sources shell/[0-9]*.sh + per-OS file
│   ├── .bashrc          ← sources .bash_profile
│   ├── .bash_local      ← per-host scratchpad (overridden locally)
│   ├── .git-completion.bash
│   ├── .inputrc
│   ├── .python_startup
│   ├── .screenrc
│   ├── .tmux.conf
│   ├── .vim/
│   └── .vimrc
├── shell/               ← bash config modules, sourced by absolute path (NOT symlinked)
│   ├── 00-platform.sh   ← uname → $platform
│   ├── 05-bash_local.sh ← source ~/.bash_local
│   ├── 10-git.sh        ← git completion + D/S/U aliases
│   ├── 20-vars.sh       ← PATH, EDITOR, HISTCONTROL, …
│   ├── 30-locale.sh     ← LANG / LC_*
│   ├── 40-prompt.sh     ← PS1 colors + prompt
│   ├── 50-ssh.sh        ← (dead, kept for history)
│   ├── 60-less.sh       ← LESS_TERMCAP_*
│   ├── 70-grep.sh       ← grep alias + G() function
│   ├── 80-tar.sh        ← tarU / tarA
│   ├── 90-tools.sh      ← V / P / K / cp -i / make / time / …
│   ├── 95-tmux.sh       ← (dead, kept for history)
│   ├── 99-go.sh         ← (dead, kept for history)
│   ├── darwin.sh        ← per-OS: ls -G + LSCOLORS
│   └── linux.sh         ← per-OS: ls --color=auto + LS_COLORS
├── bin/
│   ├── prepare.sh       ← installer (clones repo, creates symlinks)
│   └── sys_info         ← cpu% / pmem% printer for the .screenrc caption
├── claude/
│   └── backlog/
│       └── fixes.md     ← known issues + planned cleanups
├── CLAUDE.md            ← project-level guidance for Claude Code
├── com.apple.Terminal.plist
└── README.md
```

## Loading flow

```
                   ┌─→ ~/.bash_profile  (login shell, mac default)
shell starts ──────┤
                   └─→ ~/.bashrc → source ~/.bash_profile  (non-login, ubuntu default)
                                          │
                          ~/.bash_profile (symlink → home/.bash_profile)
                                          │
                                  PROFILE_DIR=~/.local/.profile
                                          │
                                  for f in shell/[0-9]*.sh; source $f
                                          │
                                  case $platform in
                                    darwin) source shell/darwin.sh
                                    linux)  source shell/linux.sh
                                  esac
```

## Setup

```sh
cd
curl -O https://raw.githubusercontent.com/inn-goose/profile/master/bin/prepare.sh
chmod +x prepare.sh
./prepare.sh
```

`prepare.sh` clones this repo to `~/.local/.profile/` and symlinks every dotfile in
`home/` into `$HOME`. The `shell/` modules stay in the repo and are sourced by
absolute path from `home/.bash_profile`.

## Per-host overrides

`~/.bash_local` is the per-host scratchpad — the repo ships a minimal default,
but on each machine you can replace the symlink with a host-specific file (e.g.
`.bash_local.work`, `.bash_local.personal`) and put machine-specific aliases or
env vars there. Secrets (tokens, API keys) belong here, never in the repo.

## See also

- [`claude/backlog/fixes.md`](claude/backlog/fixes.md) — known issues + planned cleanups
- [Sonoma caps-lock cursor fix](https://stackoverflow.com/questions/77248249/disable-macos-sonoma-text-insertion-point-cursor-caps-lock-indicator)
