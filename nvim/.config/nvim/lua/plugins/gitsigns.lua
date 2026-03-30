return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local function prompt_revision(default)
        local revision = vim.fn.input("Revision: ", default)
        if revision == nil or revision == "" then
          return nil
        end
        return revision
      end

      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signs_staged = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        current_line_blame = false,
        attach_to_untracked = true,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          map("n", "]h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gs.nav_hunk("next")
            end
          end, "Next Git Hunk")

          map("n", "[h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gs.nav_hunk("prev")
            end
          end, "Previous Git Hunk")

          map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
          map("n", "<leader>hi", gs.preview_hunk_inline, "Preview Hunk Inline")
          map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
          map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
          map("v", "<leader>hs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, "Stage Selected Hunk")
          map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
          map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle Git Blame")
          map("n", "<leader>tw", gs.toggle_word_diff, "Toggle Word Diff")

          map("n", "<leader>gb", function()
            local revision = prompt_revision("origin/main")
            if revision then
              gs.change_base(revision, true)
            end
          end, "Git Change Base")

          map("n", "<leader>gv", function()
            local revision = prompt_revision("origin/main")
            if revision then
              gs.diffthis(revision)
            else
              gs.diffthis()
            end
          end, "Git Diff This")

          map("n", "<leader>gV", function()
            gs.diffthis()
          end, "Git Diff This Against Index")

          map("n", "<leader>gS", function()
            local revision = prompt_revision("origin/main")
            if revision then
              gs.show(revision)
            end
          end, "Git Show Revision")
        end,
      })
    end,
  },
}
