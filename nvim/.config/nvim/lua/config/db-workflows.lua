local M = {}

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "sql",
    callback = function(args)
      vim.keymap.set("n", "<leader>db", function()
        vim.cmd.write()

        local file = vim.api.nvim_buf_get_name(0)
        if file == "" then
          vim.notify("No file associated with current buffer", vim.log.levels.WARN)
          return
        end

        vim.system({
          "/Applications/DBeaver.app/Contents/MacOS/dbeaver",
          "-f",
          file,
        }, { detach = true })
      end, {
        buffer = args.buf,
        desc = "Open current SQL file in DBeaver",
      })
    end,
  })
end

return M
