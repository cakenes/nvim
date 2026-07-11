return {
    "shaunsingh/nord.nvim",
    -- "cakenes/nord.nvim",
    config = function()
        vim.g.nord_italic = true
        vim.g.nord_borders = true
        vim.g.nord_disable_background = false

        -- Use `:colorscheme` (not require("nord").set() directly) so the
        -- ColorScheme autocmd fires; plugins like indent-blankline rely on
        -- it to recompute their highlight groups against nord's colors.
        vim.cmd.colorscheme("nord")

        local colors = require("nord.colors")

        -- Rainbow Delimiters (Using Nord's vibrant palette)
        vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = colors.nord11 })
        vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = colors.nord13 })
        vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = colors.nord9 })
        vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = colors.nord12 })
        vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = colors.nord14 })
        vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = colors.nord15 })
        vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = colors.nord8 })

        -- Notification and UI Components
        vim.api.nvim_set_hl(0, "NotifyBackground", { bg = colors.nord0 })

        -- Diagnostics
        vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = colors.nord10, bg = "NONE" })
        vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = colors.nord4, bg = "NONE" })
        vim.api.nvim_set_hl(0, "DiagnosticUnderLineInfo", { sp = colors.nord10, undercurl = true })
        vim.api.nvim_set_hl(0, "DiagnosticUnderLineHint", { sp = colors.nord4, undercurl = true })

        -- NeoTree and Selection
        vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = colors.nord1 })
        vim.api.nvim_set_hl(0, "NeoTreeFileNameOpened", { fg = colors.nord8, bg = "NONE", bold = true })

        -- GitGutter / Gitsigns Line Highlights
        vim.api.nvim_set_hl(0, "GitSingsDeleteLn", { bg = colors.nord11, blend = 20 })
        vim.api.nvim_set_hl(0, "GitSingsChangeLn", { bg = colors.nord13, blend = 20 })
        vim.api.nvim_set_hl(0, "GitSignsAddLn", { bg = colors.nord14, blend = 20 })

        -- Borders
        vim.api.nvim_set_hl(0, "LazyGitBorder", { fg = colors.nord3, bg = "NONE" })
        vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.nord3, bg = "NONE" })

        -- Git Blame
        vim.api.nvim_set_hl(0, "GitBlame", { fg = colors.nord3, bg = colors.nord0 })

        -- Scrollbar
        vim.api.nvim_set_hl(0, "ScrollbarHandle", { bg = colors.nord3, fg = "NONE" })
        vim.api.nvim_set_hl(0, "ScrollbarSearch", { bg = colors.nord0, fg = colors.nord14 })
        vim.api.nvim_set_hl(0, "ScrollbarSearchHandle", { bg = colors.nord3, fg = colors.nord14 })

        -- Search Lens
        vim.api.nvim_set_hl(0, "HlSearchLens", { fg = colors.nord3, bg = "NONE", blend = 100 })
        vim.api.nvim_set_hl(0, "HlSearchLensNear", { fg = colors.nord3, bg = "NONE", blend = 100 })
        vim.api.nvim_set_hl(0, "HlSearchLensCurrent", { fg = colors.nord3, bg = "NONE", blend = 100 })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "json", "jsonc" },
            callback = function()
                vim.api.nvim_set_hl(0, "jsonStringMatch", { fg = "#d8dee9" })
                vim.api.nvim_set_hl(0, "jsonQuote", { fg = "#d8dee9" })
                vim.api.nvim_set_hl(0, "jsonFold", { fg = "#d8dee9" })
            end,
        })
    end,
}
