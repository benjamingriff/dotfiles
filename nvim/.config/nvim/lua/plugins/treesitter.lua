return {
  "nvim-treesitter/nvim-treesitter",
  run = ":TSUpdate",  -- Automatically update the parsers when installing/updating
  config = function()
    require("nvim-treesitter.configs").setup {
      ensure_installed = { "lua", "python", "go", "javascript", "html", "css" },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
    }
  end,
}
