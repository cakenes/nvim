return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
            callback = function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client.name == "ts_ls" then
                    local ft = vim.bo[event.buf].filetype
                    if ft == "javascript" or ft == "javascriptreact" then
                        vim.lsp.buf_detach_client(event.buf, client.id)
                        return
                    end
                end
                local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                end
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                -- ts_ls's documentHighlights request can crash tsserver
                -- ("configFileSpecs" undefined, an upstream TypeScript bug) when it
                -- reloads the configured project's file list. Skip cursor-hold
                -- highlighting for ts_ls to avoid triggering the crash.
                if
                    client
                    and client.name ~= "ts_ls"
                    and client.server_capabilities.documentHighlightProvider
                then
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = event.buf,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = event.buf,
                        callback = vim.lsp.buf.clear_references,
                    })
                end
            end,
        })
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
        local servers = {
            ts_ls = {
                filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
            },
            lua_ls = {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                "${3rd}/luv/library",
                                unpack(vim.api.nvim_get_runtime_file("", true)),
                            },
                        },
                        completion = {
                            callSnippet = "Replace",
                        },
                    },
                },
            },
        }
        require("mason").setup({
            ui = {
                border = "rounded",
                backdrop = 100,
                width = 0.8,
                height = 0.8,
            },
        })
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
            "stylua",
        })
        require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
        require("mason-lspconfig").setup({
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                    require("lspconfig")[server_name].setup(server)
                end,
            },
        })
    end,
}
