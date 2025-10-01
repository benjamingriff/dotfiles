return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      formatters_by_ft = {
        typescript = { "prettier" },
        javascript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
      },
      format_on_save = function(bufnr)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name:match("%.ts$") or name:match("%.js$") or name:match("%.json$")
          or name:match("%.ya?ml$")
        then
          return { lsp_fallback = false, timeout_ms = 2000 }
        end
        return nil
      end,
    },
  },
}
