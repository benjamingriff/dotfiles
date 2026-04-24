# `rs-ssm`

`rs-ssm` manages Redshift SSM tunnels in a hidden tmux session and exposes a small CLI:

- `rs-ssm connect <profile>`
- `rs-ssm status [profile]`
- `rs-ssm stop <profile>`
- `rs-ssm logs <profile>`
- `rs-ssm attach <profile>`

The script expects a local config at:

```text
~/.bin/rs-ssm.env
```

A tracked example is installed alongside it:

```text
~/.bin/rs-ssm.env.example
```

Copy the example, add real values, and keep the real file untracked.

## Config format

Profiles are listed in `RS_SSM_PROFILES` and use uppercased env keys with `-` converted to `_`.

Example:

```sh
RS_SSM_PROFILES="mini-pep analytics-prod"

RS_SSM_MINI_PEP_PROFILE="shared-dev"
RS_SSM_MINI_PEP_REGION="us-east-2"
RS_SSM_MINI_PEP_TARGET="i-0a56a6ad655747009"
RS_SSM_MINI_PEP_HOST="mini-pep-us-east-2.634188077497.us-east-2.redshift-serverless.amazonaws.com"
RS_SSM_MINI_PEP_REMOTE_PORT="5439"
RS_SSM_MINI_PEP_LOCAL_PORT="4000"

RS_SSM_ANALYTICS_PROD_PROFILE="shared-prod"
RS_SSM_ANALYTICS_PROD_REGION="eu-west-2"
RS_SSM_ANALYTICS_PROD_TARGET="i-0123456789abcdef0"
RS_SSM_ANALYTICS_PROD_HOST="analytics-prod.eu-west-2.redshift.amazonaws.com"
RS_SSM_ANALYTICS_PROD_REMOTE_PORT="5439"
RS_SSM_ANALYTICS_PROD_LOCAL_PORT="4001"
```

## How it works

- Each profile runs in its own window inside the tmux session `rs-ssm`.
- `connect` reuses a healthy tunnel, or recreates a stale one automatically.
- `status` checks both tmux window existence and whether the configured local port is listening.
- `attach` jumps into the hidden tmux session so you can answer MFA prompts or inspect the live output.
- The tmux status bar shows compact state via `rs-ssm tmux-status`.

## Notes

- If your AWS auth flow prompts for MFA during startup, run `rs-ssm attach <profile>` to answer it in the tmux window.
- `logs` prints the last captured pane output without attaching.
- `stop` kills the tmux window for that profile.
