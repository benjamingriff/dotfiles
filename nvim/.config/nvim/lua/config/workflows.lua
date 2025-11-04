local M = {}

function M.setup()
  vim.keymap.set("n", "<leader>opo", "<cmd>cd ~/repos/vault<cr>")
  vim.keymap.set(
    "n",
    "<leader>opf",
    "<cmd>Telescope find_files search_dirs={'/Users/benjamingriffiths/repos/vault'}<cr>"
  )
  vim.keymap.set(
    "n",
    "<leader>opg",
    "<cmd>Telescope live_grep search_dirs={'/Users/benjamingriffiths/repos/vault'}<cr>"
  )
  vim.keymap.set("n", "<leader>oo", "<cmd>cd ~/repos/open-vault<cr>")
  vim.keymap.set(
    "n",
    "<leader>of",
    "<cmd>Telescope find_files search_dirs={'/Users/benjamingriffiths/repos/open-vault'}<cr>"
  )
  vim.keymap.set(
    "n",
    "<leader>og",
    "<cmd>Telescope live_grep search_dirs={'/Users/benjamingriffiths/repos/open-vault'}<cr>"
  )
end

return M
