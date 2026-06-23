# SQLFluff in Neovim

This dotfiles repo wires SQLFluff into Neovim in two places:

- `conform.nvim` formats `sql`, `mysql`, and `plsql` buffers with `sqlfluff fix -`.
- `nvim-lint` reports SQLFluff diagnostics through `vim.diagnostic`.

The editor setup expects `sqlfluff` to be available on `PATH`. It does not install SQLFluff through Mason.

## Install globally

For the current editor setup, install SQLFluff globally so Neovim can execute it directly:

```bash
uv tool install sqlfluff
```

If you want dbt templating support in the editor too, install the templater plugin and your adapter globally as well:

```bash
uv tool install sqlfluff sqlfluff-templater-dbt dbt-<adapter>
```

Replace `dbt-<adapter>` with the adapter your project uses, for example `dbt-bigquery` or `dbt-postgres`.

After installing with `uv tool`, restart Neovim or confirm the binary is visible with:

```vim
:echo executable('sqlfluff')
```

## Recommended project config

For fast editor feedback in dbt models, use the Jinja templater with dbt builtins.
Add one of the following to the SQL or dbt repo.

`pyproject.toml`:

```toml
[tool.sqlfluff.core]
dialect = "athena"
templater = "jinja"

[tool.sqlfluff.templater.jinja]
apply_dbt_builtins = true
```

`.sqlfluff`:

```ini
[sqlfluff]
dialect = athena
templater = jinja

[sqlfluff:templater:jinja]
apply_dbt_builtins = True
```

Use `athena` for Athena-backed dbt projects. Change `dialect` for other warehouses, such as `bigquery`, `postgres`, or `snowflake`.

## Optional dbt-templater mode

If a specific dbt project needs full macro rendering instead of the faster Jinja mode, switch that project to:

```toml
[tool.sqlfluff.core]
templater = "dbt"
```

Then add the corresponding `tool.sqlfluff.templater.dbt` settings required by that repo, such as `project_dir` or `profiles_dir`.

## Notes

- SQLFluff formatting only runs when a supported config file exists in the project root because the formatter is pinned to the nearest root containing `.sqlfluff`, `pyproject.toml`, `tox.ini`, `setup.cfg`, or `pep8.ini`.
- dbt models usually work without a custom Neovim filetype because they are still edited as `.sql` buffers.
- Dadbod query buffers can format on save as long as their filetype resolves to `sql`, `mysql`, or `plsql` and the buffer lives under a project root with SQLFluff config.
