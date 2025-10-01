return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    formatters_by_ft = {
      python = { "ruff_format" },
    },
    formatters = {
      ruff_format = {
        command = "ruff",
        args = { "format", "-" },
        stdin = true,
      },
    },
    format_on_save = {
      lsp_fallback = false,
      timeout_ms = 2000,
    },
  },
}
