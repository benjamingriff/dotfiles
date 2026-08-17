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
