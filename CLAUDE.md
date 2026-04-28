# Claude Code — project notes

This repo holds personal dotfiles and a modular bash profile. Cross-platform
(macOS + Ubuntu). Read this before making changes.

## Layout (don't reorganize without a reason)

- `home/` — every file here is symlinked into `$HOME` by `bin/prepare.sh`.
- `shell/` — bash config modules, sourced by absolute path from `home/.bash_profile`. **Not** symlinked.
- `shell/[0-9]*-name.sh` — numbered prefix controls load order. Drop in a new file with the right number to add a concern.
- `shell/{darwin,linux}.sh` — per-OS tail; loaded after the numbered modules via `case "$platform"`.
- `bin/` — install scripts.
- `claude/backlog/fixes.md` — running list of known issues. When fixing one, remove the entry.

## Conventions

- **No secrets in the repo.** Tokens, API keys, emails, names, hostnames, IPs — none of it. Use `~/.bash_local` (per-host, not tracked) for that. The repo's `home/.bash_local` is intentionally minimal.
- **Behaviour-preserving moves vs. behaviour-changing fixes are separate commits.** Reorganization that keeps every line as-is is one kind of change; deleting/rewriting/optimizing is another. Don't mix them.
- **The `if [ -n "$PS1" ]` guard wraps the loader, not each module.** Modules assume interactive context.
- **Per-OS code goes in `shell/darwin.sh` or `shell/linux.sh`.** If a shared module starts branching on `$platform`, that's a smell — push the branch into the per-OS file.
- **`$PROFILE_DIR` is hardcoded** to `~/.local/.profile` in `home/.bash_profile`. That's where `prepare.sh` clones to. Don't change without updating the installer.

## Don't

- Don't `git push`.
- Don't add `Co-Authored-By` lines to commits.
- Don't use heredocs for commit messages — single-line `git commit -m "…"` only.
- Don't run `prepare.sh` automatically as part of testing — it `rm -rf ~/.local/.profile` first.
- Don't add files to `home/` for things that don't need to be in `$HOME`. Most config belongs in `shell/`.

## Do

- Update `claude/backlog/fixes.md` when you spot a new issue you don't have time to fix.
- Update `README.md` when the layout changes.
- Test changes by sourcing the modules in a clean bash:
  ```bash
  bash --noprofile --norc -c '
    PS1=x
    PROFILE_DIR=/path/to/this/repo
    for f in "$PROFILE_DIR"/shell/[0-9]*.sh; do source "$f"; done
    case "$platform" in
      darwin) source "$PROFILE_DIR/shell/darwin.sh" ;;
      linux)  source "$PROFILE_DIR/shell/linux.sh" ;;
    esac
    # inspect: alias, env, $platform, declare -F, etc.
  '
  ```

## Install model (recap)

```
prepare.sh clones repo → ~/.local/.profile/
                              │
                              ├─ home/.* ─ ─ ─ symlinked into $HOME
                              ├─ shell/    sourced by absolute path
                              └─ bin/      not symlinked

~/.bash_profile (symlink) → ~/.local/.profile/home/.bash_profile
                                  │
                                  └─ for f in ~/.local/.profile/shell/[0-9]*.sh; source $f
                                  └─ source ~/.local/.profile/shell/$platform.sh
```
