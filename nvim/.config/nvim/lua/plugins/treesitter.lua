return {
  "nvim-treesitter/nvim-treesitter",
  run = ":TSUpdate",  -- Automatically update the parsers when installing/updating
  config = function()
    require("nvim-treesitter.configs").setup {
      -- Specify the list of languages you want to install.
      -- You can also use "all" to install every supported parser.
      ensure_installed = { "lua", "python", "javascript", "html", "css" },
      
      -- Enable syntax highlighting
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      -- Enable indentation based on Treesitter's parsing
      indent = {
        enable = true,
      },
    }
  end,
}
