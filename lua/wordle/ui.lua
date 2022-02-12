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

ui.block = block

return ui
