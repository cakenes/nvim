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

-- Escapes Lua pattern magic characters so a literal string can be
-- used with string.gsub for the live replacement preview.
local function lua_pattern_escape(s)
    return (s:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1"))
end

-- Blue border/title styling for our search & replace input boxes.
vim.api.nvim_set_hl(0, "FindReplaceBorder", { fg = "#61afef" })
vim.api.nvim_set_hl(0, "FindReplaceTitle", { fg = "#61afef", bold = true })

-- Opens a simple single-line floating input box, centered on screen.
-- on_change(text) fires on every keystroke, on_confirm(text)
-- fires on <CR>, on_cancel() fires on <Esc>.
local function open_input_box(title, on_change, on_confirm, on_cancel)
    local src_win = vim.api.nvim_get_current_win()

    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })

    local width = 60
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = 1,
        row = math.floor((vim.o.lines - 1) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = title,
        title_pos = "center",
    })

    vim.wo[win].winhighlight = "Normal:FindReplaceNormal,FloatBorder:FindReplaceBorder,FloatTitle:FindReplaceTitle"

    vim.cmd("startinsert!")

    local confirmed = false
    local closed = false

    local function close()
        if closed then
            return
        end
        closed = true
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
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

    -- Safety net: no matter how the window ends up closing (our own
    -- <CR>/<Esc> handlers, losing focus, another plugin stealing the
    -- keypress, etc.), make sure the cancel path runs unless we explicitly
    -- confirmed. This guarantees the buffer always reverts on abort.
    vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(win),
        once = true,
        callback = function()
            closed = true
            if vim.api.nvim_win_is_valid(src_win) then
                vim.api.nvim_set_current_win(src_win)
            end
            if not confirmed and on_cancel then
                on_cancel()
            end
        end,
    })

    vim.keymap.set({ "i", "n" }, "<CR>", function()
        local text = current_text()
        confirmed = true
        close()
        on_confirm(text)
    end, { buffer = buf })

    vim.keymap.set({ "i", "n" }, "<Esc>", function()
        close()
    end, { buffer = buf })
end

-- Opens the replace input box for search_text, live-previewing the
-- substitution directly in the buffer as the user types (instead of a
-- separate list). `lua_find_pattern` is a Lua pattern (already escaped)
-- matching the same text as `vim_pattern` (used only for the occurrence
-- count). Edits are merged into a single undo step via :undojoin.
-- Highlighting always targets the exact spans of what is currently shown
-- (original match text while empty, the freshly inserted replacement once
-- typed) via matchaddpos, so it never lights up coincidental substrings.
local function open_replace_input(opts)
    local buf_lines = vim.api.nvim_buf_get_lines(opts.main_buf, 0, -1, false)

    local originals = {}
    local order = {}
    for lnum, line in ipairs(buf_lines) do
        if line:find(opts.lua_find_pattern) then
            originals[lnum] = line
            table.insert(order, lnum)
        end
    end

    local started = false
    local highlight_ids = {}

    local function clear_highlight()
        if #highlight_ids > 0 then
            vim.api.nvim_win_call(opts.main_win, function()
                for _, id in ipairs(highlight_ids) do
                    pcall(vim.fn.matchdelete, id)
                end
            end)
            highlight_ids = {}
            vim.cmd("redraw")
        end
    end

    local function set_highlight(spans)
        clear_highlight()
        if #spans == 0 then
            return
        end
        vim.api.nvim_win_call(opts.main_win, function()
            for i = 1, #spans, 8 do
                local chunk = {}
                for j = i, math.min(i + 7, #spans) do
                    table.insert(chunk, spans[j])
                end
                local ok, id = pcall(vim.fn.matchaddpos, "IncSearch", chunk)
                if ok then
                    table.insert(highlight_ids, id)
                end
            end
        end)
        vim.cmd("redraw")
    end

    -- Replaces every occurrence in `line` with `replacement`, returning the
    -- resulting text and the {line, col, len} span of each inserted
    -- replacement occurrence (1-indexed column) for precise highlighting.
    local function build_replacement(line, lnum, replacement)
        local parts = {}
        local spans = {}
        local pos = 1
        while true do
            local s, e = line:find(opts.lua_find_pattern, pos)
            if not s then
                table.insert(parts, line:sub(pos))
                break
            end
            table.insert(parts, line:sub(pos, s - 1))
            local col = 0
            for _, piece in ipairs(parts) do
                col = col + #piece
            end
            table.insert(parts, replacement)
            if #replacement > 0 then
                table.insert(spans, { lnum, col + 1, #replacement })
            end
            pos = (e >= s) and (e + 1) or (pos + 1)
        end
        return table.concat(parts), spans
    end

    local function write_lines(get_text)
        local all_spans = {}
        vim.api.nvim_win_call(opts.main_win, function()
            for _, lnum in ipairs(order) do
                if started then
                    pcall(vim.cmd, "undojoin")
                end
                local new_line, spans = get_text(lnum)
                vim.api.nvim_buf_set_lines(opts.main_buf, lnum - 1, lnum, false, { new_line })
                started = true
                for _, span in ipairs(spans) do
                    table.insert(all_spans, span)
                end
            end
        end)
        vim.cmd("redraw")
        return all_spans
    end

    local function restore()
        write_lines(function(lnum)
            return originals[lnum], {}
        end)
        clear_highlight()
    end

    local function preview(text)
        local safe_repl = text:gsub("%%", "%%%%")
        local spans = write_lines(function(lnum)
            return build_replacement(originals[lnum], lnum, safe_repl)
        end)
        set_highlight(spans)
    end

    -- Highlights the original (unmodified) match spans, used while the
    -- replacement text is still empty.
    local function highlight_originals()
        local spans = {}
        for _, lnum in ipairs(order) do
            local pos = 1
            local line = originals[lnum]
            while true do
                local s, e = line:find(opts.lua_find_pattern, pos)
                if not s then
                    break
                end
                table.insert(spans, { lnum, s, e - s + 1 })
                pos = (e >= s) and (e + 1) or (pos + 1)
            end
        end
        set_highlight(spans)
    end

    highlight_originals()

    open_input_box("Replace '" .. opts.search_text .. "' (" .. opts.count .. " occurrence(s))", function(text)
        if text == "" then
            write_lines(function(lnum)
                return originals[lnum], {}
            end)
            highlight_originals()
        else
            preview(text)
        end
    end, function(new_text)
        clear_highlight()
        if new_text == nil or new_text == "" or new_text == opts.search_text then
            restore()
        end
        if opts.on_done then
            opts.on_done()
        end
    end, function()
        restore()
        if opts.on_done then
            opts.on_done()
        end
    end)
end

function replace_all_of_cursor_word()
    local word = vim.fn.expand("<cword>")
    if not word or word == "" then
        return
    end

    local main_win = vim.api.nvim_get_current_win()
    local main_buf = vim.api.nvim_win_get_buf(main_win)

    local vim_pattern = "\\<" .. vim.fn.escape(word, "\\/.*$^~[]") .. "\\>"
    local count = vim.fn.searchcount({ pattern = vim_pattern, maxcount = 0 }).total

    if count == 0 then
        return
    end

    local lua_find_pattern = "%f[%w_]" .. lua_pattern_escape(word) .. "%f[^%w_]"

    open_replace_input({
        main_win = main_win,
        main_buf = main_buf,
        search_text = word,
        vim_pattern = vim_pattern,
        count = count,
        lua_find_pattern = lua_find_pattern,
    })
end

function find_and_replace_prompt()
    local main_win = vim.api.nvim_get_current_win()
    local main_buf = vim.api.nvim_win_get_buf(main_win)
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

    open_input_box("Search", set_highlight, function(search_text)
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

        clear_highlight()

        open_replace_input({
            main_win = main_win,
            main_buf = main_buf,
            search_text = search_text,
            vim_pattern = pattern,
            count = count,
            lua_find_pattern = lua_pattern_escape(search_text),
        })
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
