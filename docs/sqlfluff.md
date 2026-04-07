# SQLFluff in Neovim

This dotfiles repo wires SQLFluff into Neovim in two places:

- `conform.nvim` formats `sql` buffers with `sqlfluff fix -`.
- `nvim-lint` reports SQLFluff diagnostics through `vim.diagnostic`.

The editor setup expects `sqlfluff` to come from the active project environment, not Mason.

## Install in a SQL or dbt project

For the recommended editor-focused setup, install SQLFluff in the project environment:

```bash
uv add --dev sqlfluff
```

If you want full dbt templating in that project later, also install the dbt templater plugin and your dbt adapter package:

```bash
uv add --dev sqlfluff sqlfluff-templater-dbt dbt-<adapter>
```

Replace `dbt-<adapter>` with the adapter your project uses, for example `dbt-bigquery` or `dbt-postgres`.

## Recommended project config

For fast editor feedback in dbt models, use the Jinja templater with dbt builtins.
Add one of the following to the SQL or dbt repo.

`pyproject.toml`:

```toml
[tool.sqlfluff.core]
dialect = "bigquery"
templater = "jinja"

[tool.sqlfluff.templater.jinja]
apply_dbt_builtins = true
```

`.sqlfluff`:

```ini
[sqlfluff]
dialect = bigquery
templater = jinja

[sqlfluff:templater:jinja]
apply_dbt_builtins = True
```

Change `dialect` to match the warehouse used by the project.

## Optional dbt-templater mode

If a specific dbt project needs full macro rendering instead of the faster Jinja mode, switch that project to:

```toml
[tool.sqlfluff.core]
templater = "dbt"
```

Then add the corresponding `tool.sqlfluff.templater.dbt` settings required by that repo, such as `project_dir` or `profiles_dir`.

## Notes

- SQLFluff formatting only runs when a supported config file exists in the project root.
- dbt models usually work without a custom Neovim filetype because they are still edited as `.sql` buffers.
