local opt = vim.opt

-- General settings
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.wrap = false
opt.breakindent = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.cursorline = true
opt.splitright = true
opt.splitbelow = true
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.completeopt = "menu,menuone,noselect"

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

