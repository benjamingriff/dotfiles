# Creating a launchd agent (macOS) — a follow-along guide

A cheat-sheet for wiring up a background job on macOS, written for future-me.
The worked example is the `claude-seed` poller (`~/.bin/claude-seed-status`),
but the recipe is the same for anything you want to run on a schedule.

---

## What launchd is

**launchd** is macOS's built-in job manager — the Mac equivalent of `cron` on
Linux. It starts system services, keeps things alive, and runs jobs on a timer.

A job is described by a `.plist` XML file. There are two flavours:

| Type | Lives in | Runs as | Runs when |
|------|----------|---------|-----------|
| **Agent** | `~/Library/LaunchAgents/` | you | you're logged in (GUI session) |
| **Daemon** | `/Library/LaunchDaemons/` | root | at boot, before login |

**For anything user-facing (needs your PATH, your `gh` token, your tmux) you want an _agent_.** Daemons are for system-level services and need root. Everything below is about agents.

Naming convention for the file and the `Label`: reverse-DNS, e.g.
`com.proximie.claude-seed-poll.plist`. Keep the filename (minus `.plist`) and
the `Label` identical — it saves confusion later.

---

## The recipe

### 1. Write the thing you want to run

Make it a standalone script that works when you run it by hand first. launchd
gives you a bare environment, so **use absolute paths inside the script** and
don't rely on shell aliases or a sourced `~/.zshrc`.

```bash
~/.bin/claude-seed-status poll   # test it manually — must work before you schedule it
```

### 2. Write the plist

Drop this in `~/Library/LaunchAgents/<label>.plist`. This is the exact template
the claude-seed poller uses:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.proximie.claude-seed-poll</string>

    <key>ProgramArguments</key>
    <array>
        <string>/Users/bengriffiths/.bin/claude-seed-status</string>
        <string>poll</string>
    </array>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/bengriffiths/.bin</string>
    </dict>

    <key>StartInterval</key>
    <integer>1800</integer>

    <key>RunAtLoad</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/Users/bengriffiths/.claude/.seed-poll.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/bengriffiths/.claude/.seed-poll.log</string>
</dict>
</plist>
```

Key-by-key:

| Key | What it does |
|-----|--------------|
| `Label` | Unique id. Must match the filename. |
| `ProgramArguments` | The command as an array — **program first, then each arg as its own `<string>`**. Not one big string. |
| `EnvironmentVariables` → `PATH` | launchd's default PATH is tiny. List every dir your tools live in (`/opt/homebrew/bin` for Homebrew, `~/.bin` for your scripts). This is the #1 cause of "works by hand, fails under launchd". |
| `StartInterval` | Run every N **seconds** (1800 = 30 min). See scheduling options below. |
| `RunAtLoad` | Also run once immediately when loaded / at login. |
| `StandardOutPath` / `StandardErrorPath` | Where stdout/stderr go. **Set these** — otherwise a broken job fails silently and you'll have nothing to debug. |

### 3. Validate the XML

A malformed plist fails silently. Always lint first:

```bash
plutil -lint ~/Library/LaunchAgents/com.proximie.claude-seed-poll.plist
# → "... OK"
```

### 4. Load it

Modern syntax (`bootstrap`), targeting your GUI session:

```bash
UID=$(id -u)
launchctl bootstrap gui/$UID ~/Library/LaunchAgents/com.proximie.claude-seed-poll.plist
launchctl enable   gui/$UID/com.proximie.claude-seed-poll
```

It loads on every login automatically from then on — you only `bootstrap` once.

### 5. Verify

```bash
UID=$(id -u)
launchctl print gui/$UID/com.proximie.claude-seed-poll | grep -iE 'state|runs|interval'
# state = running, runs = 1, run interval = 1800 seconds
```

---

## Scheduling: `StartInterval` vs `StartCalendarInterval`

- **Every N seconds** → `StartInterval` (integer, as above). Simplest.
- **At specific clock times** → `StartCalendarInterval`, e.g. every weekday at 09:00:

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key><integer>9</integer>
    <key>Minute</key><integer>0</integer>
</dict>
```

Omit a field to mean "every". Give an array of dicts for multiple times.

Note: if the Mac is asleep at the scheduled moment, launchd runs the job once
on wake (it doesn't run it once per missed interval).

---

## Everyday commands

All use `gui/$(id -u)/<label>` as the target.

```bash
UID=$(id -u)
L=com.proximie.claude-seed-poll

launchctl print gui/$UID/$L            # full status + config
launchctl kickstart -k gui/$UID/$L     # run it RIGHT NOW (great for testing)
launchctl list | grep claude-seed      # is it registered? (col 2 = last exit code)
tail -f ~/.claude/.seed-poll.log       # watch its output
```

## Editing an existing agent

launchd caches the plist, so after editing the file you must reload:

```bash
UID=$(id -u)
PLIST=~/Library/LaunchAgents/com.proximie.claude-seed-poll.plist
launchctl bootout gui/$UID "$PLIST"      # unload old version
plutil -lint "$PLIST"                    # re-validate after your edit
launchctl bootstrap gui/$UID "$PLIST"    # load new version
```

## Removing an agent completely

```bash
UID=$(id -u)
launchctl bootout gui/$UID ~/Library/LaunchAgents/com.proximie.claude-seed-poll.plist
rm ~/Library/LaunchAgents/com.proximie.claude-seed-poll.plist
```

---

## Gotchas (the things that actually bite)

1. **PATH is nearly empty under launchd.** Absolute paths in the script + an
   explicit `EnvironmentVariables > PATH` in the plist. This catches everyone.
2. **No SSH agent.** A background job usually can't use your SSH keys, so
   `git fetch` over SSH may silently fail. Prefer token-auth tools (`gh`) or an
   HTTPS remote for anything a launchd job needs to pull. (This is exactly why
   the seed poller uses `gh api` first and only falls back to `git`.)
3. **Silent failures.** No log paths = no clue why it didn't run. Always set
   `StandardOutPath` / `StandardErrorPath`.
4. **Forgot to reload after editing.** launchd runs the *cached* copy until you
   `bootout` + `bootstrap`.
5. **`load`/`unload` are the old syntax.** They still work but `bootstrap` /
   `bootout` / `kickstart` / `print` are the modern per-session commands and
   give far better error messages.
6. **Filename ≠ Label mismatch.** Keep them identical or you'll target the wrong
   thing.

---

## Reference: the plist keys worth knowing

| Key | Type | Purpose |
|-----|------|---------|
| `Label` | string | unique id (= filename) |
| `ProgramArguments` | array | command + args |
| `EnvironmentVariables` | dict | env for the job (esp. `PATH`) |
| `StartInterval` | integer | run every N seconds |
| `StartCalendarInterval` | dict / array | run at clock times |
| `RunAtLoad` | bool | run once on load/login |
| `KeepAlive` | bool / dict | restart if it exits (for long-running services, not timers) |
| `WorkingDirectory` | string | cwd for the job |
| `StandardOutPath` / `StandardErrorPath` | string | log files |

`KeepAlive` vs `StartInterval`: use `StartInterval` for "run a task periodically"
(a poller), and `KeepAlive` for "keep this daemon alive" (a server that should
never stay dead). Don't set both.
