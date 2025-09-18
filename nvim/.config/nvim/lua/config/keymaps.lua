local M = {}

function M.setup()
  vim.keymap.set("n", "<leader>q", vim.diagnostic.open_float)
  vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
  vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", { silent = true })
end

return M
