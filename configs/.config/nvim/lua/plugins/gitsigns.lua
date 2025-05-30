return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol',
            delay = 200,
            ignore_whitespace = false,
        },
        current_line_blame_formatter = '<author>, <author_time:%d %B %Y> - <summary>',
      })
    end,
  },
}

-- https://github.com/lewis6991/gitsigns.nvim
