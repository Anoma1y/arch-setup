-- General
vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"

-- Use system clipboard
vim.o.clipboard = "unnamedplus"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.keymap.set('n', '<CR>', 'o<Esc>k')
vim.keymap.set('n', '<S-CR>', 'O<Esc>j')

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.lazy")

-- Open Telescope on start
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argv(0) == "" then
			require("telescope.builtin").find_files()
		end
	end,
})
