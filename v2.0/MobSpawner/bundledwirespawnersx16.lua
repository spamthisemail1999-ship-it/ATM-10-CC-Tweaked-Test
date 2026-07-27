------------------------------------------------------------
-- ATM10 Touchscreen Bundled Cable Controller
-- CC:Tweaked + ProjectRed Bundled Cable
------------------------------------------------------------

--=============================
-- USER CONFIGURATION
--=============================

-- Which side is the bundled cable connected to?
local BUNDLE_SIDE = "right"

-- Edit these however you want.
-- label = text shown on the monitor
-- color = bundled cable wire

local buttons = {
    {label="Machine 1",  color=colors.white},
    {label="Machine 2",  color=colors.orange},
    {label="Machine 3",  color=colors.magenta},
    {label="Chief Barbarian",  color=colors.lightBlue},

    {label="Machine 5",  color=colors.yellow},
    {label="Machine 6",  color=colors.lime},
    {label="Machine 7",  color=colors.pink},
    {label="Machine 8",  color=colors.gray},

    {label="Machine 9",  color=colors.lightGray},
    {label="Machine 10", color=colors.cyan},
    {label="Machine 11", color=colors.purple},
    {label="Machine 12", color=colors.blue},

    {label="Machine 13", color=colors.brown},
    {label="Machine 14", color=colors.green},
    {label="Machine 15", color=colors.red},
    {label="Machine 16", color=colors.black},
}

------------------------------------------------------------
-- DO NOT EDIT BELOW UNLESS YOU WANT TO MODIFY THE PROGRAM
------------------------------------------------------------

local monitor = peripheral.find("monitor")

if not monitor then
    error("No monitor attached.")
end

monitor.setTextScale(0.5)
monitor.setBackgroundColor(colors.black)
monitor.clear()

local buttonState = {}
local layout = {}

for i = 1, #buttons do
    buttonState[i] = false
end

local BUTTON_WIDTH = 10
local BUTTON_HEIGHT = 3

local START_X = 2
local START_Y = 2

------------------------------------------------------------

local function updateBundled()

    local output = 0

    for i = 1, #buttons do
        if buttonState[i] then
            output = colors.combine(output, buttons[i].color)
        end
    end

    redstone.setBundledOutput(BUNDLE_SIDE, output)

end

------------------------------------------------------------

local function drawButton(index)

    local b = layout[index]

    local bg

    if buttonState[index] then
        bg = colors.green
    else
        bg = colors.red
    end

    monitor.setBackgroundColor(bg)

    for y = b.y, b.y + b.h - 1 do
        monitor.setCursorPos(b.x, y)
        monitor.write(string.rep(" ", b.w))
    end

    local label = buttons[index].label

    if #label > b.w then
        label = label:sub(1, b.w)
    end

    monitor.setCursorPos(
        b.x + math.floor((b.w - #label) / 2),
        b.y + 1
    )

    monitor.write(label)

    monitor.setBackgroundColor(colors.black)

end

------------------------------------------------------------

local function drawScreen()

    monitor.clear()

    local index = 1

    for row = 0, 3 do
        for col = 0, 3 do

            layout[index] = {
                x = START_X + col * (BUTTON_WIDTH + 1),
                y = START_Y + row * (BUTTON_HEIGHT + 1),
                w = BUTTON_WIDTH,
                h = BUTTON_HEIGHT
            }

            drawButton(index)

            index = index + 1
        end
    end

end

------------------------------------------------------------

local function handleTouch(x, y)

    for i, b in ipairs(layout) do

        if x >= b.x and x < b.x + b.w and
           y >= b.y and y < b.y + b.h then

            buttonState[i] = not buttonState[i]

            drawButton(i)

            updateBundled()

            return

        end
    end

end

------------------------------------------------------------

drawScreen()
updateBundled()

while true do

    local event, side, x, y = os.pullEvent("monitor_touch")

    handleTouch(x, y)

end