local M = {}

function M.setup()
  vim.opt.expandtab = true
  vim.opt.tabstop = 2
  vim.opt.softtabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.clipboard = "unnamedplus"
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.swapfile = false
  vim.opt.backup = false
  vim.opt.writebackup = false
  vim.opt.undofile = false
  vim.o.timeout = true
  vim.o.timeoutlen = 300 -- default ~1000; try 200–300 for snappier mappings
  vim.o.ttimeoutlen = 10
end

return M
