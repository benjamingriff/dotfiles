local parsers = {
  "lua",
  "python",
  "go",
  "javascript",
  "html",
  "css",
  "sql",
  "markdown",
  "markdown_inline",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = function()
    require("nvim-treesitter").install(parsers)
  end,
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "lua",
        "python",
        "go",
        "javascript",
        "html",
        "css",
        "sql",
        "markdown",
      },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
