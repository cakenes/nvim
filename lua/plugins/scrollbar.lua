return {
    "petertriho/nvim-scrollbar",
    dependencies = { "kevinhwang91/nvim-hlslens" },
    config = function()
        require("scrollbar").setup({
            handlers = {
                cursor = false,
                search = true,
            },
        })

        require("hlslens").setup()

        require("scrollbar.handlers.search").setup()
    end,
}
