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
      },
      format_on_save = function(bufnr)
        local format_on_save = {
          javascript = true,
          json = true,
          python = true,
          sql = true,
          typescript = true,
          yaml = true,
        }

        if format_on_save[vim.bo[bufnr].filetype] then
          return { lsp_fallback = false, timeout_ms = 2000 }
        end

        return nil
      end,
    },
  },
}
