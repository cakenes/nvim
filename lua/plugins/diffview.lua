return {
    {
        "sindrets/diffview.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
        config = function()
            local diffview = require("diffview")
            diffview.setup({})
        end,
    },
}
