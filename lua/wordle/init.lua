local utils = require("wordle.utils")

local wordle_buf = vim.api.nvim_create_buf(false, false)
local wordle_win

--- Current time table
local time = os.date("!*t")

-- Reset to 0:00
time.hour = 0
time.min = 0
time.sec = 0

--- Current date UNIX timestamp
local timestamp = os.time(time)

-- Set current date timestamp as random seed
math.randomseed(timestamp)

-- Set up dictionary and today's word
local words = require("wordle.list")
local index = math.random(#words)
local word = words[index]

-- Set up wordle metadata
local wordle = {
    status = {},
    state = {},
    attempt = 1,
    finished = false,
    correct = 0,
}
for idx = 1,6 do
    wordle.status[idx] = {
        0,
        0,
        0,
        0,
        0,
    }
end


--- Process gained input on <CR>
function wordle.check()
    wordle.correct = 0
    if wordle.finished then
        if wordle.attempt > 6 then
        else
        end
        for idx=1,wordle.attempt do
            if idx > 6 then return end
        end
        return
    end
    if #wordle.state[wordle.attempt] ~= 5 then
        return
    end
    local actual = vim.split(word, "")
    local exists = false
    for _, existing in pairs(words) do
        if existing == table.concat(wordle.state[wordle.attempt]) then
            exists = true
            break
        end
    end
    if not exists then
        return
    end
    for idx, letter in ipairs(wordle.state[wordle.attempt]) do
        if actual[idx] == letter then
            wordle.status[wordle.attempt][idx] = 2
            wordle.correct = wordle.correct + 1
        elseif string.find(word, letter) then
            wordle.status[wordle.attempt][idx] = 1
        else
            wordle.status[wordle.attempt][idx] = 0
        end
    end
    if wordle.correct == 5 then
        wordle.finished = true
        return
    elseif wordle.attempt == 6 then
        wordle.finished = true
    end
    wordle.attempt = wordle.attempt + 1
end

local alphabet = vim.split("abcdefghijklmnopqrstuvwxyz", "")

--- Handle input
--- @param letter string char to save
function wordle.input(letter)
    if wordle.finished then
        return
    end
    if #wordle.state[wordle.attempt] == 5 then
        return
    end
    table.insert(wordle.state[wordle.attempt], letter)
end

--- Remove char from input table
function wordle.pop()
    table.remove(wordle.state[wordle.attempt])
end

--- Set up gui
function wordle.play()
    for idx = 1,6 do
        wordle.state[idx] = {}
    end
    vim.api.nvim_buf_set_lines(wordle_buf, 0, -1, true, {})
    vim.api.nvim_buf_set_option(wordle_buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(wordle_buf, "filetype", "wdn")
    local width = vim.api.nvim_win_get_width(0)
    local height = vim.api.nvim_win_get_height(0)
    local win_width = math.floor(width * 0.9)
    local win_height = math.floor(height * 0.9)

    wordle_win = vim.api.nvim_open_win(wordle_buf, true, {
        relative = "win",
        win = 0,
        width = win_width,
        height = win_height,
        col = math.floor((width - win_width) / 2) - 1,
        row = math.floor((height - win_height) / 2) - 1,
        border = "solid",
        style = "minimal",
    })
    utils.wmap("<CR>", "<cmd>lua require'wordle'.check()<cr>", wordle_buf)
    utils.wmap("<bs>", "<cmd>lua require'wordle'.pop()<cr>", wordle_buf)
    utils.wmap("<C-c>", "<cmd>bd!<cr>", wordle_buf)
    for _, char in ipairs(alphabet) do
        utils.wmap(char, "<cmd>lua require'wordle'.input(" .. '"' .. char .. '"' .. ")<CR>", wordle_buf)
    end
end

return wordle
