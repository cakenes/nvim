return {
    "Mofiqul/vscode.nvim",
    config = function()
        require("vscode").setup({
            italic_comments = true,
            disable_nvimtree_bg = true,
        })
        vim.cmd.colorscheme("vscode")

        vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = "#D16969" })
        vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#D7BA7D" })
        vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#569CD6" })
        vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#CE9178" })
        vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = "#6A9955" })
        vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#C586C0" })
        vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = "#4EC9B0" })

        local c = require("vscode.colors").get_colors()

        vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = c.vscLineNumber, bg = "NONE" })
        vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = c.vscLineNumber, bg = "NONE" })
        vim.api.nvim_set_hl(0, "DiagnosticUnderLineInfo", { fg = c.vscLineNumber, bg = "NONE" })
        vim.api.nvim_set_hl(0, "DiagnosticUnderLineHint", { fg = c.vscLineNumber, bg = "NONE" })
        vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = c.vscDarkBlue })

        vim.api.nvim_set_hl(0, "GitSingsDeleteLn", { fg = "#222020", bg = "NONE" })
        vim.api.nvim_set_hl(0, "GitSingsChangeLn", { fg = "#242221", bg = "NONE" })
        vim.api.nvim_set_hl(0, "GitSignsAddLn", { fg = "#222522", bg = "NONE" })

        vim.api.nvim_set_hl(0, "LazyGitBorder", { fg = c.vscLineNumber, bg = "NONE" })
        vim.api.nvim_set_hl(0, "FloatBorder", { fg = c.vscLineNumber, bg = "NONE" })

        vim.api.nvim_set_hl(0, "GitBlame", { fg = c.vscLineNumber, bg = "#222222" })

        vim.api.nvim_set_hl(0, "NeoTreeFileNameOpened", { fg = c.vscBlue, bg = "NONE", bold = true })

        vim.api.nvim_set_hl(0, "ScrollbarHandle", { bg = c.vscDarkBlue, fg = "NONE" })
        vim.api.nvim_set_hl(0, "ScrollbarSearch", { bg = "#1E1E1E", fg = "#6A9955" })
        vim.api.nvim_set_hl(0, "ScrollbarSearchHandle", { bg = c.vscDarkBlue, fg = "#6A9955" })

        vim.api.nvim_set_hl(0, "HlSearchLens", { fg = c.vscLineNumber, bg = "NONE", blend = 100 })
        vim.api.nvim_set_hl(0, "HlSearchLensNear", { fg = c.vscLineNumber, bg = "NONE", blend = 100 })
        vim.api.nvim_set_hl(0, "HlSearchLensCurrent", { fg = c.vscLineNumber, bg = "NONE", blend = 100 })
    end,
}
