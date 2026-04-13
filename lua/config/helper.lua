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
