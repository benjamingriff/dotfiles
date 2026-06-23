return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
		config = function()
			require("rose-pine").setup({
				variant = "auto", -- auto, main, moon, or dawn
				dark_variant = "main", -- main, moon, or dawn
				dim_inactive_windows = false,
				extend_background_behind_borders = true,

				enable = {
					terminal = true,
					legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
					migrations = true, -- Handle deprecated options automatically
				},

				styles = {
					bold = true,
					italic = true,
					transparency = false,
				},

				groups = {
					border = "muted",
					link = "iris",
					panel = "surface",

					error = "love",
					hint = "iris",
					info = "foam",
					note = "pine",
					todo = "rose",
					warn = "gold",

					git_add = "foam",
					git_change = "rose",
					git_delete = "love",
					git_dirty = "rose",
					git_ignore = "muted",
					git_merge = "iris",
					git_rename = "pine",
					git_stage = "iris",
					git_text = "rose",
					git_untracked = "subtle",

					h1 = "iris",
					h2 = "foam",
					h3 = "rose",
					h4 = "gold",
					h5 = "pine",
					h6 = "foam",
				},

				palette = {
					main = {
						base = "#111111",
						pine = "#3e9fb0",
						bash_orange = "#ff7a5c",
						bash_red = "#ff4d6d",
						bash_yellow = "#eb6f92",
					},
				},

				-- NOTE: Highlight groups are extended (merged) by default. Disable this
				-- per group via `inherit = false`
				highlight_groups = {
					-- Make SQL/dbt feel closer to the richer Python highlighting.
					["@keyword.sql"] = { fg = "iris", bold = true },
					["@keyword.operator.sql"] = { fg = "rose" },
					["@conditional.sql"] = { fg = "iris", bold = true },
					["@repeat.sql"] = { fg = "iris", bold = true },
					["@operator.sql"] = { fg = "rose" },
					["@function.sql"] = { fg = "foam" },
					["@function.builtin.sql"] = { fg = "foam", bold = true },
					["@type.sql"] = { fg = "gold" },
					["@string.sql"] = { fg = "pine" },
					["@number.sql"] = { fg = "gold" },
					["@variable.sql"] = { fg = "foam" },
					["@variable.member.sql"] = { fg = "foam" },
					["@property.sql"] = { fg = "foam" },
					["@field.sql"] = { fg = "foam" },
					["@constant.sql"] = { fg = "gold" },
					["@punctuation.bracket.sql"] = { fg = "subtle" },
					["@punctuation.delimiter.sql"] = { fg = "subtle" },

					-- dbt/Jinja bits that appear inside SQL models.
					["@keyword.jinja"] = { fg = "iris", bold = true },
					["@function.jinja"] = { fg = "foam" },
					["@variable.jinja"] = { fg = "rose" },
					["@string.jinja"] = { fg = "pine" },
					["@punctuation.bracket.jinja"] = { fg = "iris" },
					["@punctuation.special.jinja"] = { fg = "iris" },

					-- YAML, including GitHub Actions and dbt schema/source files.
					["@property.yaml"] = { fg = "foam", bold = true },
					["@field.yaml"] = { fg = "foam", bold = true },
					["@string.yaml"] = { fg = "text" },
					["@string.special.yaml"] = { fg = "rose" },
					["@number.yaml"] = { fg = "gold" },
					["@boolean.yaml"] = { fg = "iris", bold = true },
					["@constant.yaml"] = { fg = "gold" },
					["@operator.yaml"] = { fg = "rose" },
					["@punctuation.delimiter.yaml"] = { fg = "subtle" },

					-- Shell commands, especially inside GitHub Actions `run: |` blocks.
					-- Keep these deliberately warm so embedded bash feels visually distinct
					-- from the cooler YAML keys around it.
					["@function.bash"] = { fg = "bash_orange", bold = true },
					["@function.call.bash"] = { fg = "bash_orange", bold = true },
					["@keyword.bash"] = { fg = "bash_red", bold = true },
					["@conditional.bash"] = { fg = "bash_red", bold = true },
					["@repeat.bash"] = { fg = "bash_red", bold = true },
					["@variable.bash"] = { fg = "bash_yellow", italic = true },
					["@string.bash"] = { fg = "rose" },
					["@number.bash"] = { fg = "bash_orange" },
					["@operator.bash"] = { fg = "bash_red" },
					["@punctuation.special.bash"] = { fg = "bash_red" },
					["@punctuation.bracket.bash"] = { fg = "bash_orange" },
				},



				before_highlight = function(group, highlight, palette)
					-- Disable all undercurls
					-- if highlight.undercurl then
					--     highlight.undercurl = false
					-- end
					--
					-- Change palette colour
					-- if highlight.fg == palette.pine then
					--     highlight.fg = palette.foam
					-- end
				end,
			})

			vim.cmd("colorscheme rose-pine")
			-- vim.cmd("colorscheme rose-pine-main")
			-- vim.cmd("colorscheme rose-pine-moon")
			-- vim.cmd("colorscheme rose-pine-dawn")
		end,
	},
}
