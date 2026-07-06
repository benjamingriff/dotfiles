local sqlfluff_root_files = {
  ".sqlfluff",
  "pep8.ini",
  "pyproject.toml",
  "setup.cfg",
  "tox.ini",
}

local function sqlfluff_cwd(_, ctx)
  local filename = ctx and ctx.filename or vim.api.nvim_buf_get_name(0)

  if filename == "" then
    return nil
  end

  return vim.fs.root(filename, sqlfluff_root_files)
end

-- Only auto-format-on-save inside the SQL workbench (scratch, not version
-- controlled). Everything else — notably the dbt project — is formatted only
-- on demand via <leader>f, so PRs never pick up surprise reformatting diffs.
local function is_workbench_file(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)

  if filename == "" then
    return false
  end

  return filename:find("/%.workbench/", 1) ~= nil
end

return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_fallback = false })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        dbt = { "sqlfluff" },
        javascript = { "prettier" },
        json = { "prettier" },
        mysql = { "sqlfluff" },
        plsql = { "sqlfluff" },
        python = { "ruff_format" },
        sql = { "sqlfluff" },
        typescript = { "prettier" },
        yaml = { "prettier" },
      },
      formatters = {
        ruff_format = {
          command = "ruff",
          args = { "format", "-" },
          stdin = true,
        },
        sqlfluff = {
          command = "sqlfluff",
          args = { "fix", "-" },
          stdin = true,
          cwd = sqlfluff_cwd,
          require_cwd = true,
          -- sqlfluff exits 1 when unfixable, lint-only violations remain (e.g.
          -- AM09 — LIMIT without ORDER BY, common in exploratory queries) while
          -- still writing the best-effort fixed SQL to stdout. Accept it so the
          -- fix is applied. A genuine usage/config error exits 2+, which stays
          -- rejected and leaves the buffer untouched.
          exit_codes = { 0, 1 },
        },
      },
      -- Auto-format on save only for SQL files living in the workbench. dbt and
      -- all other files stay untouched on save and rely on <leader>f instead.
      format_on_save = function(bufnr)
        local sql_filetypes = {
          dbt = true,
          mysql = true,
          plsql = true,
          sql = true,
        }

        if sql_filetypes[vim.bo[bufnr].filetype] and is_workbench_file(bufnr) then
          return { lsp_fallback = false, timeout_ms = 2000 }
        end

        return nil
      end,
    },
  },
}
