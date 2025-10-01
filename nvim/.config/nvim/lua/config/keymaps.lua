local M = {}

function M.setup()
  vim.keymap.set("n", "<leader>q", vim.diagnostic.open_float)
  vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
  vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", { silent = true })
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename symbol" })
  vim.keymap.set("n", "<leader>nl", [[:s/\%#/\r/<CR>]], { desc = "Add new line at cursor", silent = true }
)end

return M
