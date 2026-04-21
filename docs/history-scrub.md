# Scrubbing Sensitive History

Use this runbook after removing sensitive values from the current tree.
It is written for a public GitHub repo and assumes you want a hard cut-over with a force-push.

## What to scrub

Create an untracked file at the repo root:

```text
.git-history-scrub
```

Format it as literal replacements for `git filter-repo --replace-text`:

```text
old sensitive literal==>***REMOVED***
another leaked hostname==>***REMOVED***
```

The tracked file `.git-history-scrub.example` shows the expected format.

## Safe rewrite flow

Work from a fresh mirror clone so you do not risk local uncommitted work:

```bash
git clone --mirror git@github.com-personal:benjamingriff/dotfiles.git /tmp/dotfiles-scrub.git
cd /tmp/dotfiles-scrub.git
cp /path/to/your/local/.git-history-scrub ./.git-history-scrub
git filter-repo --sensitive-data-removal --replace-text .git-history-scrub
```

## Verify the rewrite

Check that the old literals are gone before pushing:

```bash
git log -S"old sensitive literal" --all -p --
git log -S"another leaked hostname" --all -p --
```

Both commands should return no matches.

## Publish the cleaned history

Force-push the rewritten mirror:

```bash
git push --force --mirror origin
```

Anyone with an existing clone should discard it and reclone from the cleaned remote.

## Notes

- `git-filter-repo` is the preferred tool for this cleanup. If it is not installed, install it before rewriting history.
- Do not run the rewrite from a dirty working tree.
- After the force-push, audit forks, local clones, CI caches, and any backups that may still contain the old objects.
