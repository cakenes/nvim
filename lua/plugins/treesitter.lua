return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        local parsers = {
            "bash",
            "c",
            "diff",
            "html",
            "javascript",
            "jsdoc",
            "json",
            "lua",
            "luadoc",
            "markdown",
            "markdown_inline",
            "python",
            "query",
            "regex",
            "toml",
            "tsx",
            "typescript",
            "vim",
            "vimdoc",
            "yaml",
        }
        require("nvim-treesitter").update(parsers)

        -- Enable highlighting, indentation, and incremental selection per filetype
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(ev)
                local buf = ev.buf
                local ok = pcall(vim.treesitter.start, buf)
                if ok then
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })

        -- textobject move keymaps
        local move = require("nvim-treesitter-textobjects.move")
        local moves = {
            { key = "]f", fn = "goto_next_start",     query = "@function.outer" },
            { key = "]c", fn = "goto_next_start",     query = "@class.outer" },
            { key = "]F", fn = "goto_next_end",       query = "@function.outer" },
            { key = "]C", fn = "goto_next_end",       query = "@class.outer" },
            { key = "[f", fn = "goto_previous_start", query = "@function.outer" },
            { key = "[c", fn = "goto_previous_start", query = "@class.outer" },
            { key = "[F", fn = "goto_previous_end",   query = "@function.outer" },
            { key = "[C", fn = "goto_previous_end",   query = "@class.outer" },
        }
        for _, m in ipairs(moves) do
            vim.keymap.set({ "n", "x", "o" }, m.key, function()
                if vim.wo.diff then
                    vim.cmd("normal! " .. m.key)
                    return
                end
                move[m.fn](m.query, "textobjects")
            end, { desc = m.fn .. " " .. m.query })
        end
    end,
}
