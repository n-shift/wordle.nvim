local ui = {}
local block = {}

function block.new(char)
    local _block = {
        "╭───╮",
        "│ * │",
        "╰───╯",
    }
    _block[2] = _block[2]:gsub("%*", char)
    return _block
end

function block.print(box)
    for _, line in ipairs(box) do
        print(line)
    end
end

function block.chain(blocks)
    local chained = {}
    for _, _block in ipairs(blocks) do
        for idx = 1,3 do
            chained[idx] = (chained[idx] or "").." ".._block[idx].." "
        end
    end
    return chained
end

function block.from_word(word)
    local letters = vim.split(word, "")
    local blocks = {}
    for idx, letter in ipairs(letters) do
        blocks[idx] = block.new(letter)
    end
    blocks = block.chain(blocks)
    return blocks
end

function block.from_letters(letters)
    local blocks = {}
    for idx, letter in ipairs(letters) do
        blocks[idx] = block.new(letter)
    end
    blocks= block.chain(blocks)
    return blocks
end

function block.from_table_letters(tbl)
    local lines = {}
    for idx, letters in ipairs(tbl) do
        lines[idx] = block.from_letters(letters)
    end
    return lines
end

local highlight = {}

function highlight.register()
    vim.cmd("hi WordleBgUnused guibg=#3a3a3c")
    vim.cmd("hi WordleBgMisplaced guibg=#b6a22f")
    vim.cmd("hi WordleBgCorrect guibg=#39944e")
    vim.cmd("hi WordleFgUnused guifg=#3a3a3c")
    vim.cmd("hi WordleFgMisplaced guifg=#b6a22f")
    vim.cmd("hi WordleFgCorrect guifg=#39944e")
end

function highlight.border(namespace, buffer, top_line, block, status)
    local group
    if status == 0 then
        group = "WordleBgUnused"
    elseif status == 1 then
        group = "WordleBgMisplaced"
    elseif status == 2 then
        group = "WordleBgCorrect"
    else
        return
    end
    local end_dist = 7*block - 1
    local start_dist = end_dist - 4
    vim.api.nvim_buf_add_highlight(buffer, namespace, group, top_line, start_dist, end_dist)
    vim.api.nvim_buf_add_highlight(buffer, namespace, group, top_line + 1, start_dist, start_dist)
    vim.api.nvim_buf_add_highlight(buffer, namespace, group, top_line + 1, end_dist, end_dist)
    vim.api.nvim_buf_add_highlight(buffer, namespace, group, top_line + 2, start_dist, end_dist)
end

function highlight.char(namespace, buffer, top_line, block, status)
    local group
    if status == 0 then
        group = "WordleFgUnused"
    elseif status == 1 then
        group = "WordleFgMisplaced"
    elseif status == 2 then
        group = "WordleFgCorrect"
    else
        return
    end
    local dist = 7*block - 3
    vim.api.nvim_buf_add_highlight(buffer, namespace, group, top_line + 1, dist, dist+1)
end

function highlight.block(namespace, buffer, top_line, block, status)
    highlight.border(namespace, buffer, top_line, block, status)
    highlight.char(namespace, buffer, top_line, block, status)
end

ui.block = block
ui.highlight = highlight

return ui
