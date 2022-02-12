local utils = require("wordle.utils")
local ui = require("wordle.ui")


local wordle_buf = vim.api.nvim_create_buf(false, false)
local buf_empty = {}
for idx=1,24 do
    buf_empty[idx] = " "
end
local wordle_win

--- Current time table
local time = os.date("!*t")

-- Reset to 0:00
time.hour = 0
time.min = 0
time.sec = 0

--- The day Wordle has started
local initial_day = os.time({year = 2021, month = 6, day = 19})

--- Current date UNIX timestamp
local today = os.time(time)

local duration = math.floor(utils.julian(today) - utils.julian(initial_day)) + 2

-- Set up dictionary and today's word
local words = require("wordle.list")
local answers = words[1]
local valid = words[2]
local word = answers[duration]

-- Set up wordle metadata
local wordle = {
    status = {},
    state = {},
    attempt = 1,
    finished = false,
    correct = 0,
    letters = {},
}
for idx = 1, 6 do
    wordle.letters[idx] = {
        "_",
        "_",
        "_",
        "_",
        "_",
    }
end
for idx = 1, 6 do
    wordle.status[idx] = {
        0,
        0,
        0,
        0,
        0,
    }
end

local function draw()
    local ns = vim.api.nvim_create_namespace("wordle")
    local lineblocks = ui.block.from_table_letters(wordle.letters)
    vim.cmd("hi WordleGrey guibg=#3A3A3C")
    vim.cmd("hi WordleYellow guibg=#B6A22F")
    vim.cmd("hi WordleGreen guibg=#39944E")
    vim.api.nvim_buf_set_lines(wordle_buf, 0, -1, true, buf_empty)
    local b_id = 1
    for idx=0,23,4 do
        vim.api.nvim_buf_set_lines(wordle_buf, idx, idx+2, true, lineblocks[b_id])
        b_id = b_id + 1
    end
    for i = 1, wordle.attempt - 1 do
        for j = 0, 4, 1 do
            if wordle.status[i][j + 1] == 0 then
                vim.api.nvim_buf_add_highlight(wordle_buf, ns, "WordleGrey", i, j * 2, j * 2 + 1)
            elseif wordle.status[i][j + 1] == 1 then
                vim.api.nvim_buf_add_highlight(wordle_buf, ns, "WordleYellow", i, j * 2, j * 2 + 1)
            elseif wordle.status[i][j + 1] == 2 then
                vim.api.nvim_buf_add_highlight(wordle_buf, ns, "WordleGreen", i, j * 2, j * 2 + 1)
            end
        end
    end
end

--- Process gained input on <CR>
function wordle.check()
    wordle.correct = 0
    if wordle.finished then
        return
    else
        if wordle.attempt > 5 then
            print("Used your attempts")
            return
        end
        for idx = 1, wordle.attempt do
            if idx > 6 then
                return
            end
        end
    end
    if #wordle.state[wordle.attempt] ~= 5 then
        print("not 5 letters")
        return
    end
    local actual = vim.split(word, "")
    local exists = false
    for _, existing in pairs(valid) do
        if existing == table.concat(wordle.state[wordle.attempt]) then
            exists = true
            break
        end
    end
    if not exists then
        for _, existing in pairs(answers) do
            if existing == table.concat(wordle.state[wordle.attempt]) then
                exists = true
                break
            end
        end
    end
    if not exists then
        print("Invalid word")
        return
    end
    for idx, letter in ipairs(wordle.state[wordle.attempt]) do
        -- correct letter
        if actual[idx] == letter then
            wordle.status[wordle.attempt][idx] = 2
            wordle.correct = wordle.correct + 1
            -- misplaced letter
        elseif string.find(word, letter) then
            wordle.status[wordle.attempt][idx] = 1
            -- wrong letter
        else
            wordle.status[wordle.attempt][idx] = 0
        end
    end
    if wordle.correct == 5 then
        wordle.finished = true
        for i = wordle.attempt + 1, 6 do
            for j = 1, 6 do
                wordle.letters[i][j] = ""
            end
        end
    elseif wordle.attempt == 6 then
        wordle.finished = true
    end
    wordle.attempt = wordle.attempt + 1
    draw()
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
    wordle.letters[wordle.attempt][#wordle.state[wordle.attempt]] = letter
    draw()
end

--- Remove char from input table
function wordle.pop()
    wordle.letters[wordle.attempt][#wordle.state[wordle.attempt]] = "_"
    table.remove(wordle.state[wordle.attempt])
    draw()
end

--- Set up gui
function wordle.play()
    for idx = 1, 6 do
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
        border = "shadow",
        style = "minimal",
    })
    utils.wmap("<CR>", "<cmd>lua require'wordle'.check()<cr>", wordle_buf)
    utils.wmap("<esc>", "<cmd>bd!<CR>", wordle_buf)
    utils.wmap("<bs>", "<cmd>lua require'wordle'.pop()<cr>", wordle_buf)
    utils.wmap("<C-c>", "<cmd>bd!<cr>", wordle_buf)
    for _, char in ipairs(alphabet) do
        utils.wmap(char, "<cmd>lua require'wordle'.input(" .. '"' .. char .. '"' .. ")<CR>", wordle_buf)
    end
    draw()
end

return wordle
