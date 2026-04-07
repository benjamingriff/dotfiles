return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        dbt = { "sqlfluff" },
        sql = { "sqlfluff" },
      }

      local sqlfluff_augroup = vim.api.nvim_create_augroup("sqlfluff-lint", { clear = true })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = sqlfluff_augroup,
        callback = function(args)
          local filetype = vim.bo[args.buf].filetype
          local linters = lint.linters_by_ft[filetype]

          if not linters or vim.fn.executable("sqlfluff") ~= 1 then
            return
          end

          lint.try_lint(linters)
        end,
      })
    end,
  },
}
