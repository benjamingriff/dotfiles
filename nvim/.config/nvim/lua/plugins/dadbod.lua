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

      add_dbui_profile("redshift-dev", redshift_dev_url)

      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_help = 0
      vim.g.db_ui_use_postgres_views = 0
      vim.g.db_ui_winwidth = 36
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
    end,
  },
}
