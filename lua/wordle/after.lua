--- What happens after the game is finished

local after = {}
local finish_buf
local finish_win

local width

function after.finish(parent_win, h, w, col, row)
    width = w
    finish_buf = vim.api.nvim_create_buf(false, false)
    finish_win = vim.api.nvim_open_win(finish_buf, false, {
        relative = "win",
        win = parent_win,
        height = h,
        width = w,
        col = col,
        row = row,
        border = "shadow",
        style = "minimal",
    })
end

local empty_write = {}
for idx=1,23 do
    empty_write[idx] = " "
end

local function write_lines(start, ending, text)
    vim.api.nvim_buf_set_lines(finish_buf, start, ending, true, text)
end

local function write(line, text)
    write_lines(line, line, {text})
end

local function margin_text(text, margin)
    local spaces = string.rep(" ", margin/2)
    return spaces..text..spaces
end

local function state_attempts(state)
    local attempts = {}
    for idx, attempt in ipairs(state) do
        for _, status in ipairs(attempt) do
            if status == 2 then
                attempts[idx] = (attempts[idx] or "").."🟩"
            elseif status == 1 then
                attempts[idx] = (attempts[idx] or "").."🟨"
            elseif status == 0 then
                attempts[idx] = (attempts[idx] or "").."⬛"
            end
        end
    end
    return attempts
end

function after.finish_write(attempt, finished, state, day, answer)
    -- Init
    local count = attempt
    local title
    local underline = margin_text(string.rep("=", width-2), 2)
    local attempts = state_attempts(state)
    local shoutout = "Congrats!"
    answer = margin_text(answer, width - #answer)
    if not finished then
        count = "x"
        shoutout = "Failed!"
    end
    title = "Wordle "..(day-1).." "..count.."/6"
    title = margin_text(title, width-#title)
    write_lines(0, -1, empty_write)
    write(1, title)
    write(3, underline)
    for idx, line in ipairs(attempts) do
        write(idx + 3, margin_text(line, width - 10))
    end
    write(5+#attempts, margin_text("Answer:", width-7))
    write(6+#attempts, answer)
    write(8+#attempts, margin_text(shoutout, width-#shoutout))

    vim.api.nvim_buf_set_option(finish_buf, "modifiable", false)
end

return after
