return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          typescript = { "prettier" },
          javascript = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
        },
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.ts", "*.js", "*.json", "*.yaml" },
        callback = function(args)
          require("conform").format({ bufnr = args.buf })
        end,
      })
    end,
  }
}

