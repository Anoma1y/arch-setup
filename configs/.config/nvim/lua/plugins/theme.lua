return {
    {
        "rebelot/kanagawa.nvim",
        config = function()
            require('kanagawa').setup({
            theme = "wave",
            background = {
                dark = "wave",
                light = "lotus",
            },
        })
        vim.cmd("colorscheme kanagawa")
        end,
    },
}
