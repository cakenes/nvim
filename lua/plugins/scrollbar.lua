return {
    "petertriho/nvim-scrollbar",
    config = function()
        require("scrollbar").setup({
            handlers = {
                cursor = false,
                search = true,
            },
        })

        require("scrollbar.handlers.search").setup()
    end,
}
