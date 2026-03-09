return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    config = function(_, opts)
        require("codecompanion").setup(opts)
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "codecompanion",
            callback = function()
                vim.opt_local.buflisted = true
            end,
        })
    end,
    opts = {
        opts = {
            log_level = "DEBUG",
        },
        display = {
            chat = {
                start_in_insert_mode = true,
                window = {
                    layout = "buffer",
                },
            },
        },
        interactions = {
            chat = {
                adapter = "copilot",
                keymaps = {
                    close = {
                        modes = {
                            n = { "<C-q>", "q" },
                            v = { "<C-q>", "q" },
                            i = { "<C-q>" },
                        },
                        callback = "keymaps.close",
                        description = "[Chat] Close",
                    },
                    stop = {
                        modes = { 
                            n = "<C-c>",
                            v = "<C-c>",
                            i = "<C-c>",
                        },
                        callback = "keymaps.stop",
                        description = "[Request] Stop",
                    },
                },
            },
            inline = {
                adapter = "copilot",
            },
            cmd = {
                adapter = "copilot",
            },
            shared = {
                keymaps = {
                    always_accept = {
                        modes = { n = "g1", v = "g1" },
                    },
                    accept_change = {
                        modes = { n = "g2", v = "g2" },
                    },
                    reject_change = {
                        modes = { n = "g3", v = "g3" },
                    },
                },
            },
        },
    },
}
