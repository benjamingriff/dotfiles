return {
  {
    "rose-pine/neovim",
    optional = true,
    config = function()
      local group = vim.api.nvim_create_augroup("dbt-sql-highlights", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "sql", "dbt" },
        callback = function(args)
          local bufnr = args.buf

          -- Treesitter's SQL parser is not dbt/Jinja-aware, so it can stop
          -- assigning captures after template blocks or complex CTEs. These
          -- match overlays keep dbt config blocks and long qualified SELECT
          -- lists readable even when `:Inspect` says there is no item.
          vim.api.nvim_set_hl(0, "dbtJinjaDelimiter", { fg = "#c4a7e7", bold = true })
          vim.api.nvim_set_hl(0, "dbtConfigFunction", { fg = "#9ccfd8", bold = true })
          vim.api.nvim_set_hl(0, "dbtConfigKey", { fg = "#eb6f92", bold = true })
          vim.api.nvim_set_hl(0, "dbtConfigString", { fg = "#ea9a97" })
          vim.api.nvim_set_hl(0, "dbtConfigBoolean", { fg = "#c4a7e7", bold = true })
          vim.api.nvim_set_hl(0, "dbtQualifiedColumn", { fg = "#9ccfd8" })
          vim.api.nvim_set_hl(0, "dbtSqlAlias", { fg = "#f6c177", bold = true })

          local matches = {
            { "dbtJinjaDelimiter", [[{{\|}}\|{%\|%}]], 20 },
            { "dbtConfigFunction", [[\v<(config|ref|source|var|env_var|is_incremental|this|target)>\ze\s*\(]], 21 },
            { "dbtConfigKey", [[\v<[A-Za-z_][A-Za-z0-9_]*>\ze\s*\=]], 22 },
            { "dbtConfigString", [['[^']*'\|"[^"]*"]], 19 },
            { "dbtConfigBoolean", [[\v<(true|false|True|False)>]], 20 },

            -- Common final SELECT shape: table_alias.column_name. These often
            -- get no Treesitter capture in dbt models, so colour them directly.
            { "dbtQualifiedColumn", [[\v<[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*>]], 12 },
            { "dbtSqlAlias", [[\v<AS>\s+\zs[A-Za-z_][A-Za-z0-9_]*]], 13 },
          }

          for _, match in ipairs(matches) do
            vim.fn.matchadd(match[1], match[2], match[3], -1, { window = 0 })
          end
        end,
      })
    end,
  },
}
