return {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
        "LazyGit",
    },
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("telescope").load_extension("lazygit")

        -- Close the lazygit floating window (used remotely by lazygit's
        -- os.edit/os.open commands so opening a file in the parent Neovim
        -- instance also closes the lazygit popup).
        function _G.LazygitCloseFloat()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == "lazygit" then
                    pcall(vim.api.nvim_win_close, win, true)
                end
            end
        end
    end,
}
