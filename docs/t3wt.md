---
id: t3wt
aliases: []
tags: []
---

# T3 Code Worktrees with Worktrunk

T3 Code normally generates branches using the `t3code/…` prefix. For projects requiring a specific branch naming convention, use Worktrunk to create the branch and worktree first, then attach T3 Code to it.

## Shell helper

Add this function to `~/.zshrc`:

```zsh
t3wt() {
  local branch="$1"
  local base="${2:-origin/main}"
  local t3_base="${T3CODE_HOME:-$HOME/.t3}"

  if [[ -z "$branch" ]]; then
    echo "usage: t3wt <branch> [base]"
    return 2
  fi

  command wt \
    --config-set "worktree-path=\"$t3_base/worktrees/{{ repo }}/{{ branch | sanitize }}\"" \
    switch --create "$branch" \
    --base "$base" \
    --no-cd
}
```

Reload the shell:

```bash
source ~/.zshrc
```

## Create a worktree

From the main repository:

```bash
git fetch origin
t3wt 'ABC-123/feed/feat/short-description'
```

To use a different base branch:

```bash
t3wt 'ABC-123/feed/feat/short-description' 'release/2026-08'
```

The branch keeps its full name, while Worktrunk creates a filesystem-safe directory such as:

```text
~/.t3/worktrees/datalake/ABC-123-feed-feat-short-description/
```

## Open it in T3 Code

1. Create a new thread for the original project.
2. Select **Current checkout** rather than **New worktree**.
3. Open the branch selector.
4. Select the new branch marked **worktree**.
5. Start the task normally.

T3 Code will run the thread inside the existing Worktrunk worktree without creating or renaming another branch.

## Setup and cleanup

Because Worktrunk created the worktree, T3 Code’s “run on worktree create” script will not run. Use Worktrunk hooks or perform any required setup manually.

After the work is complete, stop any T3 Code threads using the worktree, then remove it:

```bash
wt remove 'ABC-123/feed/feat/short-description'
```
