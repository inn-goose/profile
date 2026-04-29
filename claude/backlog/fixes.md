# Bash profile — known issues and planned fixes

Findings from the review on 2026-04-28. Sorted by severity. Each item names the
file under `shell/` where the change lives now (after the modular split).

---

## Real bugs (will misbehave)

### ~~TERM forced to `rxvt`~~ — DONE 2026-04-29
- **Where**: was `shell/20-vars.sh` — `export TERM=rxvt`
- **Problem**: overrode the terminal's advertised `xterm-256color`. Lost 256-color support, and on bash 3.2 (Apple default) caused bracketed-paste markers (`\e[200~`/`\e[201~`) to leak through every paste because rxvt's terminfo doesn't declare the capability.
- **Fix applied**: deleted the line from `shell/20-vars.sh` and from `~/.local/.profile/.bash_profile`. Added `shell/45-readline.sh` that runs `printf '\e[?2004l'` to defensively disable bracketed paste at shell init (bash 3.2 still can't strip the markers; quickest reliable fix is to tell the terminal not to send them).

### PATH wrong on Apple Silicon
- **Where**: `shell/20-vars.sh` — `export PATH="/usr/local/bin:${PATH}"`
- **Problem**: `/usr/local/bin` is Intel Homebrew. Apple Silicon Homebrew lives at `/opt/homebrew/bin`. Today the only reason brew works is that Homebrew's installer appended its own `eval "$(brew shellenv)"` line directly to the live `~/.bash_profile` (not tracked in this repo).
- **Fix**: in `shell/darwin.sh`, add `eval "$(/opt/homebrew/bin/brew shellenv)"` (or `/usr/local/bin/brew shellenv` for Intel — detect by `[ -x /opt/homebrew/bin/brew ]`). Drop the hardcoded `/usr/local/bin` prepend in `20-vars.sh`.

### PATH is not idempotent
- **Where**: `shell/20-vars.sh`
- **Problem**: every nested interactive bash re-prepends `~/.local/bin` and `/usr/local/bin`. After three subshells the PATH is comically long.
- **Fix**: guard each prepend:
  ```bash
  case ":$PATH:" in *":/usr/local/bin:"*) ;; *) PATH="/usr/local/bin:$PATH" ;; esac
  ```

### `alias ed='vim'` shadows `ed`
- **Where**: `shell/90-tools.sh`
- **Problem**: `ed` is a real Unix utility. Aliasing it breaks anything that calls it.
- **Fix**: delete the line.

### `make -j 8` hardcoded
- **Where**: `shell/90-tools.sh` — `alias make='nice -n 20 make -j 8'`
- **Problem**: wrong on every machine that isn't 8-core. Under-utilizes 16-core, over-subscribes 4-core.
- **Fix**: per-OS via `shell/darwin.sh` / `shell/linux.sh`:
  ```bash
  # darwin.sh
  alias make="nice -n 20 make -j $(sysctl -n hw.ncpu)"
  # linux.sh
  alias make="nice -n 20 make -j $(nproc)"
  ```

### `time -l` is BSD-only
- **Where**: `shell/90-tools.sh` — `alias time='/usr/bin/time -l'`
- **Problem**: `-l` doesn't exist in GNU time on Ubuntu (uses `-v`).
- **Fix**: move per-OS. Also note `time` is a bash *builtin* — the alias only fires for simple commands, not pipelines or `(time …)`.

### `G` function has multiple issues
- **Where**: `shell/70-grep.sh`
- **Problems**:
  - Argument order `G <dir> <pattern>` is backwards from `grep <pattern> <files>`.
  - `$1` unquoted — breaks on paths with spaces.
  - `grep -v "\.git"` filters lines, not paths — drops any line *containing* `.git` (e.g., a config example).
  - Trailing `| grep "$2"` is a hack to re-add color after `grep -v` strips it.
- **Fix**: swap to `--exclude-dir=.git`; quote `$1`; reconsider arg order; rely on `--color=always` + pager instead of the re-grep trick.

---

## Subtle correctness

### Interactive guard wraps everything
- **Where**: `home/.bash_profile`
- **Problem**: `if [ -n "$PS1" ]` means PATH/EDITOR/locale/PYTHONSTARTUP are only set in interactive shells. `bash -c 'foo'` (cron, scripts, GUI launchers) gets nothing.
- **Fix**: lift env exports out of the guard. Keep prompt/aliases/echo inside.

### `echo current platform` is unconditional stdout
- **Where**: `shell/00-platform.sh`
- **Problem**: every interactive shell prints a line. Pollutes output. Breaks anything parsing this profile.
- **Fix**: delete the echo, or guard by a `$DEBUG` flag.

### Redundant root check
- **Where**: `shell/40-prompt.sh` — `if [[ ${EUID} -ne 0 && $(whoami) != "root" ]]`
- **Problem**: both halves test the same thing. `$(whoami)` is a fork+exec on every shell start.
- **Fix**: `if [[ $EUID -ne 0 ]]`.

### Six redundant LC_* exports
- **Where**: `shell/30-locale.sh`
- **Problem**: `LANG` is the fallback for any unset `LC_*`. Setting all six is cargo-cult.
- **Fix**: keep just `LANG`. Or use `LC_ALL` if you want override semantics.

### Anemic history config
- **Where**: `shell/20-vars.sh`
- **Problem**: only `HISTCONTROL=ignoredups`. Default `HISTSIZE=500` is tiny; no `histappend` so multi-tab sessions clobber each other.
- **Fix**:
  ```bash
  export HISTSIZE=50000
  export HISTFILESIZE=200000
  export HISTTIMEFORMAT='%F %T  '
  shopt -s histappend
  ```

### Missing `shopt -s checkwinsize`
- **Where**: anywhere in shell init
- **Problem**: resize a Terminal window without it and `LINES`/`COLUMNS` go stale.
- **Fix**: add `shopt -s checkwinsize` to `shell/40-prompt.sh` (or a new `shell/15-shopt.sh`).

### `PYTHONSTARTUP` exported without existence check
- **Where**: `shell/20-vars.sh`
- **Problem**: rename the file, every Python invocation prints a warning forever.
- **Fix**: `[ -f "$HOME/.python_startup" ] && export PYTHONSTARTUP="$HOME/.python_startup"`.

---

## Hygiene / dead code

### Dead SSH block
- **Where**: `shell/50-ssh.sh` (entirely commented out)
- **Fix**: delete the file. Git history is your archive.

### Dead tmux block
- **Where**: `shell/95-tmux.sh` (entirely commented out)
- **Fix**: delete the file.

### Dead Go block
- **Where**: `shell/99-go.sh` (entirely commented out; references `glide`, dead since 2018)
- **Fix**: delete the file.

### Unused prompt vars
- **Where**: `shell/40-prompt.sh` — `PS_USER_NAME`, `PS_ROOT_NAME`
- **Problem**: defined; only referenced in commented-out alternate PS1 strings.
- **Fix**: delete or actually use them.

### `tarU` / `tarA` aliases
- **Where**: `shell/80-tar.sh`
- **Problem**: capitalization scheme inconsistent with the rest. Modern `tar` auto-detects compression (`tar xf foo.tgz` works) — `tarU` is doing nothing useful.
- **Fix**: delete; rely on plain `tar`.

### Single-letter aliases (`D S U V P K`)
- **Where**: `shell/10-git.sh`, `shell/90-tools.sh`
- **Problem**: high cognitive load. `U='git pull'` hides the choice between `pull --rebase` / `fetch`. `D='git diff . | V'` shadows directories named `D`.
- **Fix**: keep some, retire the ones rarely used. Consider longer aliases (`gp`, `gs`, `gd`).

### `cp -i`, `mv -i`, `rm -i`
- **Where**: `shell/90-tools.sh`
- **Problem**: trains you to spam `y`, defeating the safety; SSH into a fresh box without the alias and `rm -rf` confidently.
- **Fix**: drop them; use `trash` (`brew install trash`) for deliberate safety.

### `GREP_COLOR=32` is deprecated
- **Where**: `shell/70-grep.sh`
- **Problem**: modern grep wants `GREP_COLORS` (plural, key=value).
- **Fix**: `export GREP_COLORS='ms=01;32'`.

---

## Structural

### macOS bash is 3.2 (ancient)
- **Where**: system-level
- **Problem**: Apple stopped updating bash at 3.2 (2007, last GPLv2 release). Missing associative arrays, `${var^^}`, `mapfile`.
- **Fix (optional)**: `brew install bash`, then `chsh -s /opt/homebrew/bin/bash`. Or accept and stay on bash 3.2.

### `bin/` script naming
- **Where**: `bin/prepare.sh`, `bin/ssh_go.sh`, `bin/add_rsa_keys`, `bin/grab_ssh_agent`
- **Problem**: three different conventions in four files (extension or no, snake_case).
- **Fix**: pick one (suggest no extension for binaries-in-spirit, `.sh` only for explicit shell-only).

---

## Notes

- Some fixes are mutually exclusive in style (e.g., keeping single-letter aliases vs. deleting them). When picking up an item, decide and stick with it across the file.
- The "do not optimize, keep as is" rule applied during the structural split. None of the items in this list have been touched yet — this file is the to-do.
