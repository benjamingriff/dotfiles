return {
  -- Mason: external tool manager
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason LSP bridge
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ruff",
          "ts_ls",
          "gopls",
          "eslint",
        },
      })
    end,
  },

  -- LSP configs
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- Lua
      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })

      -- Ruff (Python linter)
      lspconfig.ruff.setup({})

      -- TY (Python language server)
      vim.lsp.config("ty", {
        cmd = { "ty", "server" }, -- or { "tyserver" } if that’s your binary
        filetypes = { "python" },
        root_markers = { "ty.toml", "pyproject.toml", ".git" },
        settings = { ty = {} },
      })
      vim.lsp.enable("ty")

      -- ESLint (lint only, no formatting)
      lspconfig.eslint.setup({
        settings = {
          workingDirectory = { mode = "auto" },
        },
      })

      -- Keymaps
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
    end,
  },

  -- Prettier via conform.nvim
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

      -- Autoformat on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.ts", "*.js", "*.json", "*.yaml" },
        callback = function(args)
          require("conform").format({ bufnr = args.buf })
        end,
      })
    end,
  },
}
