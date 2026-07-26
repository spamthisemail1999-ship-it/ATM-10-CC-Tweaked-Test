-- Monster Spawner Toggle Panel
-- Each button is green when ON and red when OFF.
-- This version uses bundled redstone channels so you can wire multiple spawners
-- through a single computer and control them from the monitor.

local MONITOR_SIDE = "left"
local SPAWNER_COUNT = 30
local SIDES = { "back", "left", "right", "front", "top", "bottom" }
local COLORS = {
    colors.white,
    colors.orange,
    colors.magenta,
    colors.lightBlue,
    colors.yellow,
    colors.lime,
    colors.pink,
    colors.gray,
    colors.lightGray,
    colors.cyan,
    colors.purple,
    colors.blue,
    colors.brown,
    colors.green,
    colors.red,
    colors.black
}

local SPAWNER_OUTPUTS = {}
local STATES = {}

local function buildOutputMap()
    for i = 1, SPAWNER_COUNT do
        local side = SIDES[((i - 1) % #SIDES) + 1]
        local color = COLORS[((i - 1) % #COLORS) + 1]
        SPAWNER_OUTPUTS[i] = { side = side, color = color }
    end
end

local function applyOutputs()
    local masks = {}

    for i = 1, SPAWNER_COUNT do
        if STATES[i] then
            local cfg = SPAWNER_OUTPUTS[i]
            masks[cfg.side] = bit.bor(masks[cfg.side] or 0, cfg.color)
        end
    end

    for _, side in ipairs(SIDES) do
        local mask = masks[side] or 0
        redstone.setBundledOutput(side, mask)
    end
end

local function toggleSpawner(index)
    STATES[index] = not STATES[index]
    applyOutputs()
end

local function drawButton(monitor, btn, on)
    local bg = on and colors.green or colors.red
    monitor.setBackgroundColor(bg)
    monitor.setTextColor(colors.white)

    for y = btn.y, btn.y + 2 do
        monitor.setCursorPos(btn.x, y)
        monitor.write(string.rep(" ", btn.w))
    end

    monitor.setCursorPos(btn.x + 1, btn.y + 1)
    monitor.write(btn.label)
end

local function drawScreen(monitor)
    monitor.clear()
    monitor.setTextScale(0.5)
    monitor.setCursorPos(1, 1)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.write("Spawner Control")

    monitor.setCursorPos(1, 2)
    monitor.setTextColor(colors.gray)
    monitor.write("Green = ON   Red = OFF")

    local startX = 2
    local startY = 4
    local buttonW = 7
    local buttonH = 3
    local gapX = 1
    local gapY = 1

    local buttons = {}
    local idx = 1

    for row = 0, 4 do
        for col = 0, 5 do
            if idx <= SPAWNER_COUNT then
                local x = startX + col * (buttonW + gapX)
                local y = startY + row * (buttonH + gapY)
                local label = tostring(idx)
                if #label < 2 then
                    label = "0" .. label
                end
                buttons[idx] = { x = x, y = y, w = buttonW, h = buttonH, label = label }
                drawButton(monitor, buttons[idx], STATES[idx])
                idx = idx + 1
            end
        end
    end

    return buttons
end

local function findMonitor()
    local monitor = peripheral.find("monitor")
    if not monitor then
        print("No monitor found. Attach a monitor and run the program again.")
        return nil
    end

    monitor.setTextScale(0.5)
    return monitor
end

buildOutputMap()
for i = 1, SPAWNER_COUNT do
    STATES[i] = false
end

local monitor = findMonitor()
if not monitor then
    return
end

local buttons = drawScreen(monitor)
applyOutputs()

while true do
    local event, side, xPos, yPos = os.pullEvent()
    if event == "monitor_touch" then
        for i = 1, #buttons do
            local b = buttons[i]
            if xPos >= b.x and xPos < b.x + b.w and yPos >= b.y and yPos < b.y + b.h then
                toggleSpawner(i)
                drawButton(monitor, b, STATES[i])
                break
            end
        end
    elseif event == "terminate" then
        break
    end
end
