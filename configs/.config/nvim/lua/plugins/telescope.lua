return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require('telescope').setup {
                defaults = {
                    sorting_strategy = "ascending",
					file_ignore_patterns = {
						"node_modules/.*",
						".idea",
						".git/.*",
					},
					preview = {
						treesitter = false,
					}
                },
                pickers = {
                    find_files = {
                        hidden = true,
                    },
                },
                extensions = {},
            }
        end,
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
        },
    }
}
