-- Monster Spawner Toggle Panel
-- Each button is green when ON and red when OFF.
-- This version keeps the logic simple for ComputerCraft compatibility.

local SPAWNER_COUNT = 30
local SIDES = { "back", "left", "right", "front", "top", "bottom" }
local STATES = {}

local function setOutput(index, state)
    local side = SIDES[((index - 1) % #SIDES) + 1]
    redstone.setOutput(side, state)
end

local function toggleSpawner(index)
    STATES[index] = not STATES[index]
    setOutput(index, STATES[index])
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

for i = 1, SPAWNER_COUNT do
    STATES[i] = false
end

local monitor = findMonitor()
if not monitor then
    return
end

local buttons = drawScreen(monitor)

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
