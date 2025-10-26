return {
  "mrjones2014/dash.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  build = "make install", -- optional for faster search; safe to omit if issues
  config = function()
    require("dash").setup({
      -- Optional: set your default docsets globally
      -- search_engine = "duckduckgo", -- fallback if no docset matches
      -- debounce = 150,               -- ms
      -- file_type_keywords maps filetypes to Dash docsets
      file_type_keywords = {
        python = { "Python", "NumPy", "Pandas" },
        javascript = { "JavaScript", "TypeScript", "React" },
        typescript = { "TypeScript", "React" },
        lua = { "Lua", "Neovim" },
        go = { "Go" },
        rust = { "Rust" },
        sh = { "Bash" },
        html = { "HTML", "CSS" },
        css = { "CSS" },
        json = { "JSON" },
        yaml = { "YAML" },
      },
      -- Or force specific docsets always:
      -- keywords = { "Python", "Go" },
    })

    -- Load telescope extension
    pcall(require("telescope").load_extension, "dash")

    vim.keymap.set("n", "<leader>sk", function()
      require("telescope").extensions.dash.search()
    end, { desc = "Dash: search (filetype-aware)" })

    local function open_dash(query)
      vim.fn.jobstart({ "open", "dash://" .. query }, { detach = true })
    end

    vim.keymap.set("n", "KK", function()
      open_dash(vim.fn.expand("<cword>"))
    end, { desc = "Dash app: <cword>" })

  end,
}
