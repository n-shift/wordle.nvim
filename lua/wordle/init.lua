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
