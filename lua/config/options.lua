vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.timeoutlen = 0
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 15
vim.opt.hlsearch = true
vim.opt.relativenumber = false
vim.opt.number = true
vim.opt.wrap = false

-- Copilot
vim.g.copilot_no_tab_map = true

-- Indentation, sleuth will override these
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.diagnostic.config({
    underline = {
        severity = { min = vim.diagnostic.severity.WARN },
    },
    virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN },
    },
    signs = true,
    update_in_insert = false,
})
