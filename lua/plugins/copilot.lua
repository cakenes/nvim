return {
    "github/copilot.vim",
    config = function()
        vim.g.copilot_no_tab_map = true
        vim.g.copilot_settings = { selectedCompletionModel = "claude-opus-4.6" }
    end,
}

