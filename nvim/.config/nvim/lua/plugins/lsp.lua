return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig")

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gd", "<C-]>", { noremap = true, silent = true })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
      end

      -- 1) Global defaults for all LSPs
      vim.lsp.config("*", {
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- 2) Per-server customizations (only when you need to override defaults)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      vim.lsp.config("eslint", {
        settings = {
          workingDirectory = { mode = "auto" },
        },
      })

      -- If "ruff" server is available (via nvim-lspconfig), defaults are fine.
      -- Only add vim.lsp.config("ruff", { ... }) if you need overrides.

      -- 3) Custom server you defined ('ty') stays as-is
      vim.lsp.config("ty", {
        settings = {
          ty = {},
        },
      })

      -- 4) Enable servers (one call; accepts string or list)
      vim.lsp.enable({
        "lua_ls",
        "ruff",
        "eslint",
        "ty",
      })
    end,
  },
}
