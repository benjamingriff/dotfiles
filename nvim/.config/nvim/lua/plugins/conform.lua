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
        },
      },
      format_on_save = nil,
      -- Previous format-on-save setup, kept for reference:
      -- format_on_save = function(bufnr)
      --   local format_on_save = {
      --     javascript = true,
      --     json = true,
      --     mysql = true,
      --     plsql = true,
      --     python = true,
      --     sql = true,
      --     typescript = true,
      --     yaml = true,
      --   }
      --
      --   if format_on_save[vim.bo[bufnr].filetype] then
      --     return { lsp_fallback = false, timeout_ms = 2000 }
      --   end
      --
      --   return nil
      -- end,
    },
  },
}
