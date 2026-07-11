function copilot_chat(command)
    local input = vim.fn.input("Copilot Chat: ")
    if input ~= "" then
        vim.cmd(command .. " " .. input)
    end
end

function copilot_is_visible()
    local ns = vim.api.nvim_get_namespaces()["github-copilot"]
    if not ns then
        return false
    end
    local line0 = vim.fn.line(".") - 1
    local marks = vim.api.nvim_buf_get_extmarks(0, ns, { line0, 0 }, { line0, -1 }, { details = true })
    return #marks > 0
end

function copilot_suggestion_text()
    local ns = vim.api.nvim_get_namespaces()["github-copilot"]
    if not ns then
        return nil
    end
    local line0 = vim.fn.line(".") - 1
    local marks = vim.api.nvim_buf_get_extmarks(0, ns, { line0, 0 }, { line0, -1 }, { details = true })
    if #marks == 0 then
        return nil
    end
    local _, _, _, details = unpack(marks[1])
    if not details or not details.virt_text then
        return nil
    end
    local s = ""
    for _, chunk in ipairs(details.virt_text) do
        s = s .. (chunk[1] or "")
    end
    return s ~= "" and s or nil
end

function copilot_suggestion_starts_with_whitespace()
    local s = copilot_suggestion_text()
    if not s then
        return false
    end
    local first = s:sub(1, 1)
    return first == " " or first == "\t"
end

function grep_cached_files()
    local builtin = require("telescope.builtin")

    local files = vim.fn.systemlist("git ls-files --cached")

    if #files == 0 then
        vim.notify("No cached files found in Git", vim.log.levels.WARN)
        return
    end

    builtin.grep_string({ search_dirs = files })
end

function is_neotree_open()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
        if bufname:match("neo%-tree") then
            return true
        end
    end
    return false
end

function dual_neotree()
    if is_neotree_open() then
        vim.cmd("Neotree close")
        return
    else
        vim.cmd("Neotree close")
        vim.cmd("Neotree show git_status left")
        vim.cmd("belowright split | Neotree show filesystem")
    end
end

function code_companion_stop()
    local chat = require("codecompanion").last_chat()
    if chat then
        chat:stop()
    end
end

function smart_rename()
    local current_name = vim.fn.expand("<cword>")
    vim.ui.input({
        prompt = "Rename " .. current_name .. " to: ",
        default = "",
    }, function(new_name)
        if new_name and #new_name > 0 and new_name ~= current_name then
            vim.lsp.buf.rename(new_name)
        end
    end)
end

function highlight_all_of_cursor_word()
    local word = vim.fn.expand("<cword>")
    if word and word ~= "" then
        local search = "/" .. vim.pesc(word)
        vim.cmd("set hlsearch")
        vim.api.nvim_feedkeys(search, "n", false)
    end
end

function replace_all_of_cursor_word()
    local word = vim.fn.expand("<cword>")
    if not word or word == "" then
        return
    end

    local pattern = "\\<" .. vim.fn.escape(word, "\\/.*$^~[]") .. "\\>"
    local count = vim.fn.searchcount({ pattern = pattern, maxcount = 0 }).total

    if count == 0 then
        return
    end

    vim.fn.setreg("/", pattern)
    vim.cmd("set hlsearch")

    vim.ui.input({
        prompt = "Replace '" .. word .. "' (" .. count .. " occurrence(s)) with: ",
        default = "",
    }, function(new_text)
        if new_text ~= nil and new_text ~= "" and new_text ~= word then
            local replacement = vim.fn.escape(new_text, "\\/&~")
            local cursor = vim.api.nvim_win_get_cursor(0)
            vim.cmd(string.format("silent! %%s/%s/%s/g", pattern, replacement))
            vim.api.nvim_win_set_cursor(0, cursor)
        end
        vim.cmd("nohlsearch")
    end)
end

local function live_prompt(title, on_change, on_confirm, on_cancel)
    local src_win = vim.api.nvim_get_current_win()

    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })

    local width = 50
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = 1,
        row = math.floor(vim.o.lines / 2) - 1,
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = title,
        title_pos = "left",
    })

    vim.cmd("startinsert!")

    local closed = false
    local function close()
        if closed then
            return
        end
        closed = true
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_win_is_valid(src_win) then
            vim.api.nvim_set_current_win(src_win)
        end
    end

    local function current_text()
        return vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
    end

    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = buf,
        callback = function()
            on_change(current_text())
        end,
    })

    local function confirm()
        local text = current_text()
        close()
        on_confirm(text)
    end

    local function cancel()
        close()
        if on_cancel then
            on_cancel()
        end
    end

    vim.keymap.set({ "i", "n" }, "<CR>", confirm, { buffer = buf })
    vim.keymap.set({ "i", "n" }, "<Esc>", cancel, { buffer = buf })
end

function find_and_replace_prompt()
    local main_win = vim.api.nvim_get_current_win()
    local match_id = nil

    local function clear_highlight()
        if match_id then
            pcall(vim.api.nvim_win_call, main_win, function()
                pcall(vim.fn.matchdelete, match_id)
            end)
            match_id = nil
            vim.cmd("redraw")
        end
    end

    local function set_highlight(text)
        clear_highlight()
        if text == nil or text == "" then
            return
        end
        local pattern = vim.fn.escape(text, "\\/.*$^~[]")
        vim.api.nvim_win_call(main_win, function()
            local ok, id = pcall(vim.fn.matchadd, "IncSearch", pattern)
            if ok then
                match_id = id
            end
        end)
        vim.cmd("redraw")
    end

    live_prompt("Search", set_highlight, function(search_text)
        if search_text == nil or search_text == "" then
            clear_highlight()
            return
        end

        local pattern = vim.fn.escape(search_text, "\\/.*$^~[]")
        local count
        vim.api.nvim_win_call(main_win, function()
            count = vim.fn.searchcount({ pattern = pattern, maxcount = 0 }).total
        end)

        if count == 0 then
            clear_highlight()
            return
        end

        set_highlight(search_text)

        live_prompt("Replace '" .. search_text .. "' (" .. count .. " occurrence(s))", function() end, function(new_text)
            if new_text ~= nil and new_text ~= "" and new_text ~= search_text then
                local replacement = vim.fn.escape(new_text, "\\/&~")
                vim.api.nvim_win_call(main_win, function()
                    local cursor = vim.api.nvim_win_get_cursor(0)
                    vim.cmd(string.format("silent! %%s/%s/%s/g", pattern, replacement))
                    vim.api.nvim_win_set_cursor(0, cursor)
                end)
            end
            clear_highlight()
        end, clear_highlight)
    end, clear_highlight)
end

function project_old_files()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    if git_root == nil or git_root == "" then
        git_root = vim.fn.getcwd()
    end

    local files = {}
    for _, f in ipairs(vim.v.oldfiles) do
        if string.find(f, git_root, 1, true) then
            table.insert(files, f)
        end
    end

    builtin.oldfiles({
        cwd = git_root,
        only_cwd = true,
        results = files,
    })
end

function open_or_focus_copilot()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local bt = vim.api.nvim_buf_get_option(buf, "buftype")
            if bt == "terminal" then
                local name = vim.api.nvim_buf_get_name(buf)
                if name:match("copilot") then
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        if vim.api.nvim_win_get_buf(win) == buf then
                            vim.api.nvim_set_current_win(win)
                            return
                        end
                    end

                    vim.api.nvim_set_current_buf(buf)
                    return
                end
            end
        end
    end

    vim.cmd("terminal copilot")
end

function code_companion_generate()
    local prompt =
        "Fill in the function body. Infer the correct behavior from the function name, parameters, types, and surrounding context."
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" or mode == "\22" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
        vim.schedule(function()
            vim.cmd("'<,'>CodeCompanion \"" .. prompt .. '"')
        end)
    else
        vim.cmd('CodeCompanion "' .. prompt .. '"')
    end
end

function grep_visual()
    vim.cmd('normal! "vy')

    local text = vim.fn.getreg("v")

    if not text or text == "" then
        return
    end

    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    if git_root == nil or git_root == "" then
        git_root = vim.fn.getcwd()
    end

    require("telescope").extensions.live_grep_args.live_grep_args({
        default_text = text,
        cwd = git_root,
    })
end

function grep_word()
    local word = vim.fn.expand("<cword>")

    if not word or word == "" then
        return
    end

    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    if git_root == nil or git_root == "" then
        git_root = vim.fn.getcwd()
    end

    require("telescope").extensions.live_grep_args.live_grep_args({
        default_text = word,
        cwd = git_root,
    })
end

local last_grep = ""

function live_grep_remember()
    local lga = require("telescope").extensions.live_grep_args

    lga.live_grep_args({
        default_text = last_grep,

        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local action_state = require("telescope.actions.state")
                local actions = require("telescope.actions")

                local prompt = action_state.get_current_line()
                last_grep = prompt

                actions.select_default(prompt_bufnr)
            end)

            return true
        end,
    })
end
