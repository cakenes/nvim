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
