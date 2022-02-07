-- TODO: check how many letters are input
-- call functions to check
-- color stuff by going through status
-- map <BS> to delete character
-- display input in float
local wordle_buf
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

--- Dictionary length
LENGTH = 12972
local index = math.random(LENGTH)

local file = io.open("./wordle.txt")

local lines = {}
for line in file:lines() do
    table.insert(lines, line)
end
file:close()

local word = lines[index]

print(word)

local wordle = {}

local input = {}

local status = {
    "wunused",
    "wunused",
    "wunused",
    "unused",
    "unused",
}

local function check()
    for idx, letter in ipairs(input) do
        if word[idx] == letter then
            status[idx] = "correct"
        elseif string.find(word, letter) then
            status[idx] = "misplaced"
        else
            status[idx] = "unused"
        end
    end
end

local alphabet = vim.split("abcdefghijklmnopqrstuvwxyz", "")

wordle.input = function(letter)
    table.insert(input, letter)
end

wordle.play = function()
    vim.api.nvim_buf_set_lines(wordle_buf, 0, -1, true, {})
    vim.api.nvim_buf_set_option(wordle_buf, "bufhidden", "wipe")
    local width = vim.api.nvim_win_get_width(0)

    wordle_win = vim.api.nvim_open_win(wordle_buf, true, {
        relative = "win",
        win = 0,
        width = math.floor(width * 0.9),
        height = 28,
        col = 1,
        row = 1,
        border = "shadow",
        style = "minimal",
    })
    for _, char in ipairs(alphabet) do
        vim.api.nvim_buf_set_keymap(
            wordle_buf,
            "n",
            char,
            "<cmd>lua require'wordle'.input(" .. '"' .. char .. '"' .. ")<CR>",
            { noremap = true, silent = true }
        )
    end
end

return wordle
