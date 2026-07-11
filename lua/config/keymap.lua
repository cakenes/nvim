
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Open lazy" })
vim.keymap.set("n", "<leader>M", "<cmd>Mason<cr>", { desc = "Open mason" })
vim.keymap.set("n", "<leader>T", "<cmd>terminal<cr>", { desc = "Open terminal" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<C-q>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Code definition" })
vim.keymap.set({ "x", "n", "s" }, "<PageDown>", "20j", { desc = "Window: Go up", remap = true })
vim.keymap.set({ "x", "n", "s" }, "<PageUp>", "20k", { desc = "Window: Go up", remap = true })
vim.keymap.set({ "i", "x", "n" }, "<A-Up>", "<cmd>m -2<cr>", { desc = "Move line up" })
vim.keymap.set({ "i", "x", "n" }, "<A-Down>", "<cmd>m +1<cr>", { desc = "Move line down" })
vim.keymap.set("n", "<cr>", "o<Esc>", { desc = "Insert new line below" })
vim.keymap.set("n", "<S-cr>", "O<Esc>", { desc = "Insert new line above" })
vim.keymap.set({ "n", "i", "v", "s", "t" }, "~", "<Esc>", { desc = "Map tilde to Esc in all modes" })
vim.keymap.set("n", "<Tab>", ">>", { desc = "Indent line right" })
vim.keymap.set("n", "<S-Tab>", "<<", { desc = "Indent line left" })
vim.keymap.set({"v"}, "<Tab>", ">gv", { desc = "Indent right and keep selection" })
vim.keymap.set({"v"}, "<S-Tab>", "<gv", { desc = "Indent left and keep selection" })
vim.keymap.set({"v", "n"}, "<BS>", "X", { desc = "Delete char before cursor" })
vim.keymap.set({"i", "n", "v"}, "<C-a>", "<Esc>ggVG", { noremap = true })
vim.keymap.set("n", "dm", "d%", { noremap = true, desc = "Delete to matching pair" })

-- Replace
vim.keymap.set("n", "<leader>rw", function() replace_all_of_cursor_word() end, { desc = "Replace: Cursor" })
vim.keymap.set("n", "<leader>rf", function() find_and_replace_prompt() end, { desc = "Replace:  Find and replace" })

-- Ai
vim.keymap.set({"n", "v"}, "<leader>aa", "<cmd>CodeCompanion<cr>", { desc = "Ai: Agent prompt" })
vim.keymap.set({"n", "v"}, "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Ai: Chat toggle" })
vim.keymap.set({"n", "v"}, "<leader>ag", function() code_companion_generate() end, { desc = "Ai: Agent generate" })
vim.keymap.set({"n", "v"}, "<leader>as", function() code_companion_stop() end, { desc = "Ai: Stop request" })
vim.keymap.set({"n", "v"}, "<leader>ac", function() open_or_focus_copilot() end, { desc = "Ai: Copilot-cli" })
vim.keymap.set("n", "<leader>am", "<cmd>CopilotChatModels<cr>", { desc = "Code: Copilot models" })

-- Buffer
vim.keymap.set("n", "b", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",{ desc = "Buffer: List" })
vim.keymap.set("n", "<leader>bb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",{ desc = "Buffer: List" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Buffer: Delete" })
vim.keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Buffer: Delete other" })
vim.keymap.set("n", "<leader>br", "<cmd>BufferLineCloseRight<cr>", { desc = "Buffer: Delete to the right" })
vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", { desc = "Buffer: Delete to the left" })
vim.keymap.set("n", "<leader>bf", "<cmd>bdelete!<cr>", { desc = "Buffer: Force delete" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Buffer: Toggle pin" })
vim.keymap.set("n", "<leader>ba", "<cmd>bufdo bdelete<cr>", { desc = "Buffer: Delete all saved" })
vim.keymap.set("n", "<leader>bA", "<cmd>bufdo bdelete!<cr>", { desc = "Buffer: Force delete all" })
vim.keymap.set("n", "<C-Right>", "<cmd>bnext<cr>", { desc = "Buffer: Next" })
vim.keymap.set("n", "<C-Left>", "<cmd>bprevious<cr>", { desc = "Buffer: Prev" })
vim.keymap.set("n", "<C-Esc>", "<cmd>bdelete<cr>", { desc = "Buffer: Delete" })

-- Code
vim.keymap.set({"n", "v"}, "<F2>", function() smart_rename() end, { desc = "Code: Rename" })
vim.keymap.set("n", "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Code: Rename" })
vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Code: Action" })
vim.keymap.set("n", "<leader>cf", "<cmd>lua vim.lsp.buf.format()<CR>", { desc = "Code: Format" })
vim.keymap.set("n", "<leader>cd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Code: Definition" })
vim.keymap.set({"n", "v"}, "<F12>", "<cmd>Telescope lsp_definitions<cr>", { desc = "Code: Definition" })
vim.keymap.set("n", "<leader>ci", "<cmd>Telescope lsp_implementations<cr>", { desc = "Code: Implementation" })
vim.keymap.set("n", "<leader>cE", "<cmd>Telescope diagnostics<cr>", { desc = "Code: Diagnostics" })
vim.keymap.set("n", "<leader>ce", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Code: Line diagnostics" })
vim.keymap.set("n", "<leader>cs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Code: Symbols" })
vim.keymap.set("n", "<leader>cc", function() vim.fn.system("biome check --fix --unsafe") end, { desc = "Code: Biome cleanup" })

-- Debug
vim.keymap.set("n", "<leader>ds", "<cmd>DapContinue<cr>", { desc = "Debug: Start/continue" })
vim.keymap.set("n", "<leader>di", "<cmd>DapStepInto<cr>", { desc = "Debug: Step into" })
vim.keymap.set("n", "<leader>dO", "<cmd>DapStepOver<cr>", { desc = "Debug: Step over" })
vim.keymap.set("n", "<leader>do", "<cmd>DapStepOut<cr>", { desc = "Debug: Step out" })
vim.keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<cr>", { desc = "Debug: Toggle breakpoint" })

-- Git
vim.keymap.set("n", "<leader>gl", "<cmd>LazyGit<cr>", { desc = "Git: Lazygit" })

-- Explorer
vim.keymap.set("n", "<leader>ee", "<cmd>Neotree toggle<cr>", { desc = "Explorer: Toggle", nowait = true })
vim.keymap.set("n", "<leader>eg", "<cmd>Neotree git_status<cr>", { desc = "Explorer: Git status", nowait = true })
vim.keymap.set("n", "<leader>es", function () dual_neotree() end, { desc = "Explorer: Split neotree", nowait = true })
vim.keymap.set("n", "<leader>eb", "<cmd>Neotree buffers<cr>", { desc = "Explorer: Buffers", nowait = true })
vim.keymap.set("n", "<leader>ef", "<cmd>Neotree float<cr>", { desc = "Explorer: Float", nowait = true })

-- Find
vim.keymap.set("n", "<leader><space>", "<cmd>Telescope git_files<cr>", { desc = "Find: Git", nowait = true })
vim.keymap.set("v", "<leader>fv", function() grep_visual() end, { desc = "Find: Visual", nowait = true })
vim.keymap.set("n", "<leader>fw", function() grep_word() end, { desc = "Find: Word", nowait = true })
vim.keymap.set("n", "<leader>fg", function() live_grep_remember() end, { desc = "Find: Grep", nowait = true })
vim.keymap.set("n", "<leader>fG", function() grep_cached_files() end, { desc = "Find: Cached grep", nowait = true })
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find: Recent", nowait = true })
vim.keymap.set("n", "<leader>ff", function() project_old_files() end, { desc = "Find: Project recent", nowait = true })
vim.keymap.set("n", "<leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<cr>", { desc = "Find: All", nowait = true })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope git_commits<cr>", { desc = "Find: Git commit", nowait = true })
vim.keymap.set("n", "<leader>fc", "<cmd>Telescope git_bcommits<cr>", { desc = "Find: Git commit (current file)", nowait = true })
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope git_stash<cr>", { desc = "Find: Git stash", nowait = true })

-- Test
vim.keymap.set("n", "<leader>tr", "<cmd>Neotest run<cr>", { desc = "Neotest: Run nearest" })
vim.keymap.set("n", "<leader>tl", "<cmd>Neotest run last<cr>", { desc = "Neotest: Run last" })
vim.keymap.set("n", "<leader>tf", "<cmd>Neotest run file<cr>", { desc = "Neotest: Run file" })
vim.keymap.set("n", "<leader>tt", "<cmd>TroubleToggle<cr>", { desc = "Trouble: Toggle" })
vim.keymap.set("n", "<leader>tR", "<cmd>TroubleToggle lsp_references<cr>", { desc = "Trouble: References" })
vim.keymap.set("n", "<leader>td", "<cmd>TroubleToggle lsp_definitions<cr>", { desc = "Trouble: Definitions" })
vim.keymap.set("n", "<leader>ti", "<cmd>TroubleToggle lsp_implementations<cr>", { desc = "Trouble: Implementations" })
vim.keymap.set("n", "<leader>tD", "<cmd>TroubleToggle lsp_diagnostics<cr>", { desc = "Trouble: Diagnostics" })
vim.keymap.set("n", "<leader>tL", "<cmd>TroubleToggle loclist<cr>", { desc = "Trouble: Location list" })
vim.keymap.set("n", "<leader>tq", "<cmd>TroubleToggle quickfix<cr>", { desc = "Trouble: Quickfix list" })

-- Window
vim.keymap.set("n", "<A-Left>", "<C-w>h", { desc = "Window: Go left", remap = true })
vim.keymap.set("n", "<A-Down>", "<C-w>j", { desc = "Window: Go down", remap = true })
vim.keymap.set("n", "<A-Up>", "<C-w>k", { desc = "Window: Go up", remap = true })
vim.keymap.set("n", "<A-Right>", "<C-w>l", { desc = "Window: Go right", remap = true })
vim.keymap.set("n", "<D-Left>", "<C-w>h", { desc = "Window: Go left", remap = true }) -- For Mac
vim.keymap.set("n", "<D-Down>", "<C-w>j", { desc = "Window: Go down", remap = true }) -- For Mac
vim.keymap.set("n", "<D-Up>", "<C-w>k", { desc = "Window: Go up", remap = true }) -- For Mac
vim.keymap.set("n", "<D-Right>", "<C-w>l", { desc = "Window: Go right", remap = true }) -- For Mac
vim.keymap.set("n", "<C-k>", "<cmd>resize +2<cr>", { desc = "Window: Increase height" })
vim.keymap.set("n", "<C-j>", "<cmd>resize -2<cr>", { desc = "Window: Decrease height" })
vim.keymap.set("n", "<C-h>", "<cmd>vertical resize -2<cr>", { desc = "Window: Decrease width" })
vim.keymap.set("n", "<C-l>", "<cmd>vertical resize +2<cr>", { desc = "Window: Increase width" })
