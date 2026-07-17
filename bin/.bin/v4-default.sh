# Source this file to return the current shell to the default AWS account.
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_PROFILE

if [[ -n "${TMUX:-}" && -n "${TMUX_PANE:-}" ]]; then
  tmux set-option -pu -t "$TMUX_PANE" @aws_account 2>/dev/null || true
  tmux set-option -pu -t "$TMUX_PANE" @aws_account_expiry 2>/dev/null || true
fi

echo "Switched AWS identity to DEFAULT."
