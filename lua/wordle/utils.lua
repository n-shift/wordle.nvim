local utils = {}

function utils.wmap(lhs, rhs, buf)
    vim.api.nvim_buf_set_keymap(buf, "n", lhs, rhs,
    { noremap = true, silent = true })
end

function utils.julian(timestamp)
    return timestamp / 86400 + 2440587.5
end

function utils.cursor(wordle_win, attempt, letter)
    if letter == 0 then letter = 1 end
    print(wordle_win, attempt, letter)
    local row = attempt*4-2
    -- TODO: use byte-index
    local col = 11*letter-6
    vim.api.nvim_win_set_cursor(wordle_win, {row, col})
end

return utils
