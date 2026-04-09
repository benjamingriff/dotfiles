return {
  {
    "tpope/vim-dadbod",
    cmd = { "DB" },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      local redshift_dev_url = "postgresql://db_user@127.0.0.1:4000/dev?sslmode=require"
      local dbout_preview_group = vim.api.nvim_create_augroup("dadbod_ui_dbout_preview", { clear = true })

      local function add_dbui_profile(name, url)
        if vim.g.dbs == nil then
          vim.g.dbs = { { name = name, url = url } }
          return
        end

        if vim.tbl_islist(vim.g.dbs) then
          for _, profile in ipairs(vim.g.dbs) do
            if type(profile) == "table" and profile.name == name then
              return
            end
          end

          table.insert(vim.g.dbs, { name = name, url = url })
          return
        end

        if vim.g.dbs[name] == nil then
          vim.g.dbs[name] = url
        end
      end

      local function resize_dbout_preview(win)
        if not vim.api.nvim_win_is_valid(win) then
          return
        end

        if not vim.wo[win].previewwindow then
          return
        end

        local target_height = math.max(12, math.floor(vim.o.lines * 0.4))
        pcall(vim.api.nvim_win_set_height, win, target_height)
      end

      add_dbui_profile("redshift-dev", redshift_dev_url)

      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_help = 0
      vim.g.db_ui_use_postgres_views = 0
      vim.g.db_ui_winwidth = 36
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

      vim.api.nvim_create_autocmd("FileType", {
        group = dbout_preview_group,
        pattern = "dbout",
        callback = function(args)
          local win = vim.fn.bufwinid(args.buf)
          if win == -1 then
            return
          end

          vim.schedule(function()
            resize_dbout_preview(win)
          end)
        end,
      })

      vim.api.nvim_create_autocmd("VimResized", {
        group = dbout_preview_group,
        callback = function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "dbout" then
              resize_dbout_preview(win)
            end
          end
        end,
      })
    end,
  },
}
