return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function ()
            local configs = require("nvim-treesitter.configs")

            configs.setup({
                ensure_installed = {
                    "bash",
                    "c",
                    "css",
                    "diff",
                    "dockerfile",
                    "dot",
                    "gitignore",
                    "go",
                    "graphql",
                    "html",
                    "http",
                    "javascript",
                    "json",
                    "lua",
                    "make",
                    "nginx",
                    "php",
                    "python",
                    "query",
                    "regex",
                    "scss",
                    "sql",
                    "styled",
                    "tmux",
                    "twig",
                    "typescript",
                    "vim",
                    "vimdoc",
                    "xml",
                    "yaml",
                },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    }
}
