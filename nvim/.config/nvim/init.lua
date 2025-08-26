require("config.lazy")

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set clipboard=unnamedplus")
vim.cmd("set number relativenumber")

vim.lsp.enable("ty")

local hl = vim.api.nvim_set_hl

vim.keymap.set("n", "<leader>q", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
-- in init.lua or lua/keymaps.lua
vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", { silent = true })

-- Disable swap files (or set a dedicated dir)
vim.opt.swapfile = false
-- Disable backups (or set a dedicated dir)
vim.opt.backup = false
vim.opt.writebackup = false
-- Disable persistent undo (or set a dedicated dir)
vim.opt.undofile = false
