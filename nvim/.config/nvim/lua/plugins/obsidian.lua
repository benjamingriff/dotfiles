return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "vault",
        path = "~/repos/vault",
      },
      {
        name = "open-vault",
        path = "~/repos/open-vault",
      },
    },
  },
}
