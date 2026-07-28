------------------------------------------------------------
-- ATM10 Dynamic Touchscreen Bundled Controller
------------------------------------------------------------

-----------------------
-- CONFIGURATION
-----------------------

local BUNDLE_SIDE = "right"

local buttons = {
    {label="Machine 1",  color=colors.white},
    {label="Machine 2",  color=colors.orange},
    {label="Machine 3",  color=colors.magenta},
    {label="Chief Barb",  color=colors.lightBlue},

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

local monitor = peripheral.find("monitor")

if not monitor then
    error("No monitor found.")
end

monitor.setTextScale(0.5)
monitor.setBackgroundColor(colors.black)
monitor.clear()

local layout = {}
local state = {}

for i=1,#buttons do
    state[i]=false
end

------------------------------------------------------------

local function updateOutputs()

    local output = 0

    for i=1,#buttons do
        if state[i] then
            output = colors.combine(output, buttons[i].color)
        end
    end

    redstone.setBundledOutput(BUNDLE_SIDE, output)

end

------------------------------------------------------------

local function drawButton(i)

    local b = layout[i]

    if state[i] then
        monitor.setBackgroundColor(colors.red)      -- OUTPUT ACTIVE
    else
        monitor.setBackgroundColor(colors.green)    -- OUTPUT OFF
    end

    for y=b.y,b.y+b.h-1 do
        monitor.setCursorPos(b.x,y)
        monitor.write(string.rep(" ",b.w))
    end

    local text = buttons[i].label

    if #text > b.w-2 then
        text = text:sub(1,b.w-2)
    end

    monitor.setTextColor(colors.white)

    monitor.setCursorPos(
        b.x + math.floor((b.w-#text)/2),
        b.y + math.floor(b.h/2)
    )

    monitor.write(text)

end

------------------------------------------------------------

local function drawScreen()

    monitor.clear()

    local width,height = monitor.getSize()

    local cols = 4
    local rows = 4

    local gap = 1

    local buttonWidth =
        math.floor((width-(gap*(cols+1)))/cols)

    local buttonHeight =
        math.floor((height-(gap*(rows+1)))/rows)

    local index = 1

    for row=1,rows do

        for col=1,cols do

            layout[index]={
                x = gap + (col-1)*(buttonWidth+gap)+1,
                y = gap + (row-1)*(buttonHeight+gap)+1,
                w = buttonWidth,
                h = buttonHeight
            }

            drawButton(index)

            index=index+1
        end

    end

end

------------------------------------------------------------

local function handleTouch(x,y)

    for i,b in ipairs(layout) do

        if x>=b.x and
           x<=b.x+b.w-1 and
           y>=b.y and
           y<=b.y+b.h-1 then

            state[i]=not state[i]

            drawButton(i)

            updateOutputs()

            return

        end

    end

end

------------------------------------------------------------

drawScreen()
updateOutputs()

while true do

    local event = {os.pullEvent()}

    if event[1]=="monitor_touch" then

        handleTouch(event[3],event[4])

    elseif event[1]=="monitor_resize" then

        drawScreen()

    end

end