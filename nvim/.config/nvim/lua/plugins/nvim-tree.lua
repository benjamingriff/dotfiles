return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup({
      view = {
        width = 50,
        side = "right",
      },
      update_focused_file = {
        enable = true,
      },
      actions = {
        open_file = {
          quit_on_open = true, -- close the tree when opening a file
        },
      },
      filters = {
        dotfiles = false,
        git_ignored = false,
        custom = {},
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")

        local function opts(desc)
          return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
          }
        end

        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
        vim.keymap.set("n", "R", api.fs.rename_full, opts("Rename Full (move)"))
        -- Optionally make `r` also do full-path rename instead of same-dir rename:
        -- vim.keymap.set("n", "r", api.fs.rename_full, opts("Rename Full (move)"))
      end,
    })
  end,
}
