return {
    "folke/which-key.nvim",
    event = "VimEnter",
    config = function()
        require("which-key").setup()
        require("which-key").add({
            { "<leader>a", group = "[A]i", mode = { "n", "v" } },
            { "<leader>b", group = "[B]uffer", mode = { "n", "v" } },
            { "<leader>c", group = "[C]ode", mode = { "n", "v" } },
            { "<leader>d", group = "[D]ebug", mode = { "n", "v" } },
            { "<leader>e", group = "[E]xplorer", mode = { "n", "v" } },
            { "<leader>f", group = "[F]ind", mode = { "n", "v" } },
            { "<leader>g", group = "[G]oto", mode = { "n", "v" } },
            { "<leader>s", group = "[S]plit / [S]pectre", mode = { "n", "v" } },
            { "<leader>t", group = "[T]est", mode = { "n", "v" } },
        })
    end,
}

