# Dadbod in Neovim

This Neovim setup includes:

- `tpope/vim-dadbod` for database connections and query execution
- `kristijanhusak/vim-dadbod-ui` for the drawer UI
- `kristijanhusak/vim-dadbod-completion` for database-aware completion in SQL buffers

The plugins are command-driven. No new keymaps are added.

## What is configured

- `:DB` is available for ad hoc commands and buffer-local connections.
- `:DBUI` and `:DBUIToggle` open the Dadbod UI drawer.
- `nvim-cmp` includes Dadbod completions for `sql`, `mysql`, and `plsql` buffers.
- Public profile labels remain stable for `redshift-dev`, `pep-brains`, `us-dash`, and `dashboard-prod`.
- Real connection URLs are loaded from a local file at `stdpath("config") .. "/lua/local/dadbod_profiles.lua"`.
- Passwords are prompted on demand and cached in Neovim state with owner-only permissions.
- `redshift-dev` keeps its cache for 4 hours.
- `pep-brains`, `us-dash`, and `dashboard-prod` keep their caches for 7 days.
- Saved DBUI queries live under `stdpath("data") .. "/db_ui"`.
- Postgres views are disabled in DBUI because Redshift requires `g:db_ui_use_postgres_views = 0`.
- Dadbod result previews (`.dbout`) are resized to about 40% of the editor height when they open.

## Local-only setup

This repo no longer stores real database endpoints or usernames in tracked Lua files.
To use the built-in profile labels, create the ignored local config file:

```text
~/.config/nvim/lua/local/dadbod_profiles.lua
```

A tracked example lives at:

```text
~/.config/nvim/lua/local/dadbod_profiles.example.lua
```

Expected shape:

```lua
return {
  ["redshift-dev"] = {
    url = "postgresql://db_user@127.0.0.1:4000/dev?sslmode=require",
  },
  ["pep-brains"] = {
    url = "postgresql://db_user@db.example.internal:5432/app_db?sslmode=require",
  },
  ["us-dash"] = {
    url = "postgresql://db_user@db.example.internal:5432/postgres?sslmode=require",
  },
}
```

Rules:

- `url` must not include a password.
- Only profiles present in the local file are added to DBUI.
- On first connect or after cache expiry, Neovim prompts for the password and caches it locally.

## Opening the UI

Start Neovim and run:

```vim
:DBUI
```

Or toggle the drawer with:

```vim
:DBUIToggle
```

DBUI will list only the profiles you configured in the local file.

When the drawer is open:

- Press `<CR>` on a connection, schema, or table to expand it.
- Press `?` to show the built-in DBUI help.
- Press `A` to add a temporary connection from inside the drawer.

## Connection flow

1. Add the real URL to the ignored local profile file.
2. Open Neovim and run `:DBUI`.
3. Expand or connect to the profile label.
4. On a cache miss, Neovim prompts for the password, validates it with `psql`, and writes a local owner-only `PGPASSFILE`.
5. Reconnects use the cached local credentials until the cache expires or you clear it.

The cache lives in Neovim state under `stdpath("state") .. "/dadbod"`.

Useful commands:

```vim
:RedshiftDevLogin
:RedshiftDevLogout
:RedshiftDevCacheStatus
:PepBrainsLogin
:PepBrainsLogout
:PepBrainsCacheStatus
:UsDashLogin
:UsDashLogout
:UsDashCacheStatus
:DashboardProdLogin
:DashboardProdLogout
:DashboardProdCacheStatus
```

- `*Login` prompts for the password immediately and refreshes the cache.
- `*Logout` clears the cached credentials and removes the runtime auth file.
- `*CacheStatus` shows whether the profile is configured locally and when the cache expires.

## One-off connections

You can still use one-off URLs with `:DB`, `b:db`, `g:db`, or environment variables.
Those flows are unchanged, but they are easier to leak into shell history or tracked config.
For anything reusable, prefer the ignored local profile file plus the built-in prompt-and-cache flow.

Examples:

```vim
:DB postgresql://user:pass@localhost:5432/app_db select now();
:let b:db = "postgresql://user:pass@localhost:5432/app_db"
:let g:db = "postgresql://user:pass@localhost:5432/app_db"
```

## Running queries

Open a SQL buffer, write a query, and save the buffer with `:w`. DBUI query buffers execute on write.

Example:

```sql
select id, email
from users
order by id desc
limit 20;
```

## Completion

Database completion is enabled only for SQL-family buffers in this setup.

In a SQL buffer:

1. Start typing a table or column name.
2. Trigger completion with `<C-Space>` if it does not open automatically.
3. Confirm with `<CR>`.

Dadbod completion works best when the buffer has an active database connection through `b:db`, `g:db`, or a DBUI-managed query buffer.

## History cleanup

Current tracked files no longer include the real Dadbod endpoints.
To remove previously committed values from public history as well, use the runbook in `docs/history-scrub.md`.

## Notes

- Keep passwords and real connection metadata out of tracked dotfiles files.
- Cached profile files are private local state, not repo-tracked config.
- If completion is missing, verify the current SQL buffer has a valid database connection.
