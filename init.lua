vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end

vim.opt.rtp:prepend(lazypath)

vim.api.nvim_create_autocmd("CmdwinEnter", {
    callback = function()
        vim.cmd("quit")
    end,
})

-- Enable autoread to automatically reload files when they are changed outside of Neovim
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    command = "if mode() != 'c' | checktime | endif",
    pattern = "*",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "spectre_panel",
    callback = function()
        vim.keymap.set("n", "<Esc>", "<cmd>q<CR>", { buffer = true })
    end,
})

require("config.keymap")
require("config.options")
require("config.helper")
require("lazy").setup({
    spec = { { import = "plugins" } },
    ui = {
        border = "rounded",
        backdrop = 100,
        size = {
            width = 0.8,
            height = 0.8,
        },
    },
})
