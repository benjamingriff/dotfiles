return {
  {
    "github/copilot.vim"
},
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      -- LSP source for nvim-cmp
      "hrsh7th/cmp-nvim-lsp",
      -- Snippet engine + snippets (required if you want snippet placeholders)
      { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
      "saadparwaiz1/cmp_luasnip",
      -- Extra sources (optional but useful)
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Recommended for LSP snippet expansion
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        local cur_line = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        return col ~= 0 and cur_line:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- Advertise snippet capability to LSP servers
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- If you set up LSPs manually, re-setup them with these capabilities:
      local lspconfig = require("lspconfig")
      for _, server in ipairs({ "pyright", "ruff", "lua_ls", "ts_ls", "gopls", "ty" }) do
        if lspconfig[server] and not lspconfig[server].manager then
          -- Only if not already set up elsewhere
          lspconfig[server].setup({ capabilities = capabilities })
        end
      end
      -- If you already call lspconfig.<server>.setup elsewhere, pass capabilities there:
      -- lspconfig.pyright.setup({ capabilities = capabilities, ... })
      -- lspconfig.ty.setup({ capabilities = capabilities, ... })
    end,
  },
}
