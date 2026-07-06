local M = {}

local DBEAVER_APP = "/Applications/DBeaver.app"

function M.setup()
  local function open_current_file_in_dbeaver()
    vim.cmd.write()

    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
      vim.notify("No file associated with current buffer", vim.log.levels.WARN)
      return
    end

    if vim.fn.isdirectory(DBEAVER_APP) == 0 then
      vim.notify(
        "DBeaver not found at " .. DBEAVER_APP .. " (brew install --cask dbeaver-community)",
        vim.log.levels.ERROR
      )
      return
    end

    vim.system({ "open", "-a", DBEAVER_APP, file }, { text = true }, function(result)
      if result.code ~= 0 then
        vim.schedule(function()
          vim.notify(
            "Failed to open file in DBeaver: " .. vim.trim(result.stderr or result.stdout or "unknown error"),
            vim.log.levels.ERROR
          )
        end)
      end
    end)
  end

  vim.api.nvim_create_user_command("DBeaverOpen", open_current_file_in_dbeaver, {
    desc = "Open current file in DBeaver",
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sql", "mysql", "plsql", "dbt" },
    callback = function(args)
      vim.keymap.set("n", "<leader>db", open_current_file_in_dbeaver, {
        buffer = args.buf,
        desc = "Open current SQL file in DBeaver",
      })
    end,
  })
end

return M
