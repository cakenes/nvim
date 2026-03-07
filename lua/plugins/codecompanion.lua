return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        opts = {
            log_level = "DEBUG",
        },
        strategies = {
            chat = {
                adapter = "copilot",
            },
            inline = {
                adapter = "copilot",
            },
            cmd = {
                adapter = "copilot",
            },
        },
        display = {
            chat = {
                start_in_insert_mode = true,
                window = {
                    layout = "float",
                    border = "rounded",
                    width = 0.8,
                    height = 0.8,
                    relative = "editor",
                    opts = {
                        wrap = false,
                        number = false,
                        relativenumber = false,
                    },
                },
            },
        },
        interactions = {
            chat = {
                keymaps = {
                    close = {
                        modes = {
                            n = { "<C-c>", "q" },
                            v = { "<C-c>", "q" },
                            i = { "<C-c>" },
                        },
                        callback = "keymaps.close",
                        description = "[Chat] Close",
                    },
                    stop = {
                        modes = { n = "<leader>q" },
                        callback = "keymaps.stop",
                        description = "[Request] Stop",
                    },
                },
            },
        },
    },
}
