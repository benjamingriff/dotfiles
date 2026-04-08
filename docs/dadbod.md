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
- A reusable `redshift-dev` DBUI profile is available for the SSM-forwarded Redshift tunnel at `localhost:4000/dev`.
- Saved DBUI queries live under `stdpath("data") .. "/db_ui"`.
- Postgres views are disabled in DBUI because Redshift requires `g:db_ui_use_postgres_views = 0`.

## Opening the UI

Start Neovim and run:

```vim
:DBUI
```

Or toggle the drawer with:

```vim
:DBUIToggle
```

When the drawer is open:

- Press `<CR>` on a connection, schema, or table to expand it.
- Press `?` to show the built-in DBUI help.
- Press `A` to add a temporary connection from inside the drawer.

## Connecting to a database

### One-off connection with `:DB`

You can run a query directly from the command line:

```vim
:DB postgresql://user:pass@localhost:5432/app_db select now();
```

This is useful for quick checks, but it can expose credentials in shell history if you are not careful.

### Buffer-local connection with `b:db`

For normal SQL editing, set a connection on the current buffer:

```vim
:let b:db = "postgresql://user:pass@localhost:5432/app_db"
```

Then open or edit a SQL buffer and write a query. Dadbod uses that connection for execution and completion in that buffer.

### Global connection with `g:db`

If you want one default connection for the whole session:

```vim
:let g:db = "postgresql://user:pass@localhost:5432/app_db"
```

Use this only for short-lived local sessions. Avoid committing credentials into this repo.

### Environment variables and named connections

DBUI can also discover connections from environment variables or connections added in the UI. That is the safer option when you do not want secrets in your editor config.

A practical pattern is to export a connection string before launching Neovim:

```bash
export DATABASE_URL='postgresql://user:pass@localhost:5432/app_db'
nvim
```

Then use DBUI to add or reuse that connection for the session.

### Built-in Redshift profile via SSM

This setup includes a DBUI profile named `redshift-dev` for the tunnel:

```text
postgresql://db_user@127.0.0.1:4000/dev?sslmode=require
```

Use it like this:

1. Start your SSM tunnel so Redshift is reachable on `localhost:4000`.
2. Open Neovim and run `:DBUI`.
3. Select `redshift-dev`.
4. Dadbod will prompt for the password with hidden input when it actually connects.

The password is not stored in this repo or in the configured connection URL.
After a successful prompt, Dadbod keeps the password in memory for the current Neovim session, so reconnects to the same URL usually do not re-prompt until you restart Neovim.

## Running queries

Open a SQL buffer, write a query, and save the buffer with `:w`. DBUI query buffers execute on write.

Example:

```sql
select id, email
from users
order by id desc
limit 20;
```

Useful command flow:

```vim
:DBUI
```

Select a connection or table from the drawer, which opens a SQL buffer. Edit the SQL and write the file to execute it.

## Completion

Database completion is enabled only for SQL-family buffers in this setup.

In a SQL buffer:

1. Start typing a table or column name.
2. Trigger completion with `<C-Space>` if it does not open automatically.
3. Confirm with `<CR>`.

Dadbod completion works best when the buffer has an active database connection through `b:db`, `g:db`, or a DBUI-managed query buffer.

## Examples

### PostgreSQL

Buffer-local connection:

```vim
:let b:db = "postgresql://postgres:postgres@localhost:5432/postgres"
```

Query:

```sql
select current_database(), current_schema();
```

### Redshift over SSM

Built-in DBUI profile:

```text
redshift-dev
```

Equivalent URL:

```text
postgresql://db_user@127.0.0.1:4000/dev?sslmode=require
```

You can also use it directly without DBUI:

```vim
:DB postgresql://db_user@127.0.0.1:4000/dev?sslmode=require
```

If authentication is required, Dadbod prompts for the password.

### SQLite

Buffer-local connection:

```vim
:let b:db = "sqlite:db/dev.sqlite3"
```

Query:

```sql
select name
from sqlite_master
where type = 'table'
order by name;
```

## Notes

- Keep credentials out of the dotfiles repo.
- Prefer environment variables, local shell setup, or DBUI session connections over hardcoded strings in Neovim config.
- If completion is missing, verify the current SQL buffer has a valid database connection.
