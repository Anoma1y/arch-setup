-- General
vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.lazy")
