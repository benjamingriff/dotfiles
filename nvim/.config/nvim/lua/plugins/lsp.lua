return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local on_attach = function(_, bufnr)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
      end

      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })

      lspconfig.ruff.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      vim.lsp.config('ty', {
        settings = {
          ty = {
          }
        }
      })
      vim.lsp.enable('ty')

      lspconfig.eslint.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          workingDirectory = { mode = "auto" },
        },
      })
    end,
  }
}
