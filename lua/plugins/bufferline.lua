local colors = {
    -- vscode
    -- red = "#f44747",
    -- grey = "#383a42",
    -- black = "#1e1e1e",
    -- blue = "#0a7aca",

    -- nord
    red = "#BF616A", -- nord11
    grey = "#3B4252", -- nord1
    black = "#1F242C", -- nord0
    blue = "#81A1C1", -- nord9
}

local mru_counter = 0
local mru_order = {}

local function mru_sort(a, b)
    local a_order = mru_order[a.id] or 0
    local b_order = mru_order[b.id] or 0
    return a_order > b_order
end

return {
    "akinsho/bufferline.nvim",
    opts = {
        highlights = {
            background = {
                fg = colors.grey,
                bg = colors.black,
            },
            close_button = {
                fg = colors.red,
                bg = colors.black,
            },
            close_button_selected = {
                fg = colors.red,
                bg = colors.black,
            },
            buffer_selected = {
                fg = colors.blue,
                bg = colors.black,
                italic = false,
            },
        },
        options = {
            close_command = function(n)
                require("mini.bufremove").delete(n, false)
            end,
            right_mouse_command = function(n)
                require("mini.bufremove").delete(n, false)
            end,
            always_show_bufferline = true,
            diagnostics_indicator = function(_, _, diag)
                local icons = { Error = " ", Warn = " ", Hint = " ", Info = " " }
                local ret = (diag.error and icons.Error .. diag.error .. " " or "")
                    .. (diag.warning and icons.Warn .. diag.warning or "")
                return vim.trim(ret)
            end,
            offsets = {
                {
                    filetype = "neo-tree",
                    text = "Neo-tree",
                    highlight = "Directory",
                    text_align = "left",
                },
            },
        },
    },
    config = function(_, opts)
        require("bufferline").setup(opts)
        -- Auto-sort buffers by most recently used
        -- vim.api.nvim_create_autocmd("BufEnter", {
        --     callback = function()
        --         local buf = vim.api.nvim_get_current_buf()
        --         mru_counter = mru_counter + 1
        --         mru_order[buf] = mru_counter
        --         vim.schedule(function()
        --             if vim.fn.buflisted(buf) == 1 then
        --                 require("bufferline").sort_by(mru_sort)
        --             end
        --         end)
        --     end,
        -- })
    end,
}
