vim.o.cmdheight = 0
vim.o.laststatus = 0
vim.o.ruler = false
vim.o.showcmd = false
vim.o.shadafile = "NONE"
vim.o.termguicolors = true

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local path = vim.fn.argv(0)
    if path == "" then
      path = vim.fn.getcwd()
    end

    vim.cmd("enew")
    vim.cmd("startinsert")
    vim.fn.termopen({ "yazi", path }, {
      on_exit = function()
        vim.schedule(function()
          vim.cmd("quitall!")
        end)
      end,
    })
  end,
})
