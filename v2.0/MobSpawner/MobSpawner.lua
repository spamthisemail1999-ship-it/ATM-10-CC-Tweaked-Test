-- Mob Spawner Control Program

local spawnerCount = 30
local sides = { "back", "left", "right", "front", "top", "bottom" }
local states = {}
local names = dofile("mob_names.lua")
local modemSide = "right"
local channel = 1000

local function initModem()
  if peripheral.isPresent(modemSide) and peripheral.getType(modemSide) == "modem" then
    rednet.open(modemSide)
    return true
  end
  return false
end

local function sendSpawner(index, state)
  if not initModem() then
    return
  end
  rednet.send(channel + index, { spawner = index, state = state })
end

local function setOutput(index, state)
  local side = sides[(index % 6) + 1]
  redstone.setOutput(side, state)
  sendSpawner(index, state)
end

local function toggleSpawner(index)
  if states[index] == true then
    states[index] = false
  else
    states[index] = true
  end
  setOutput(index, states[index])
end

local function drawButton(monitor, btn, on)
  if on then
    monitor.setBackgroundColor(colors.black)
  else
    monitor.setBackgroundColor(colors.red)
  end
  monitor.setTextColor(colors.white)

  for y = btn.y, btn.y + btn.h - 1 do
    monitor.setCursorPos(btn.x, y)
    monitor.write(string.rep(" ", btn.w))
  end

  local textY = btn.y + math.floor(btn.h / 2)
  local textX = btn.x + math.max(1, math.floor((btn.w - #btn.label) / 2))
  monitor.setCursorPos(textX, textY)
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

  local width, height = monitor.getSize()
  local buttons = {}
  local idx = 1
  local startX = 2
  local startY = 4
  local buttonW = math.max(3, math.floor((width - 2 - 5) / 6))
  local buttonH = 3
  local gapX = 1
  local gapY = 1

  local cols = math.max(1, math.min(6, math.floor((width - startX + gapX) / (buttonW + gapX))))
  local rows = math.max(1, math.ceil(spawnerCount / cols))

  if height < 10 then
    buttonH = 1
  end

  local availableHeight = math.max(1, height - startY)
  local maxRows = math.max(1, math.floor((availableHeight + gapY) / (buttonH + gapY)))
  if maxRows < rows then
    rows = maxRows
  end

  for row = 0, rows - 1 do
    for col = 0, cols - 1 do
      if idx <= spawnerCount then
        local x = startX + col * (buttonW + gapX)
        local y = startY + row * (buttonH + gapY)
        if y + buttonH - 1 <= height then
          local label = names[idx] or tostring(idx)
          if #label < 2 then
            label = "0" .. label
          end
          buttons[idx] = { x = x, y = y, w = buttonW, h = buttonH, label = label }
          drawButton(monitor, buttons[idx], states[idx])
          idx = idx + 1
        end
      end
    end
  end

  return buttons
end

local function findMonitor()
  local monitor = peripheral.find("monitor")
  if monitor == nil then
    print("No monitor found")
    return nil
  end

  monitor.setTextScale(0.5)
  return monitor
end

for i = 1, spawnerCount do
  states[i] = false
end

local monitor = findMonitor()
if monitor == nil then
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
        drawButton(monitor, b, states[i])
        break
      end
    end
  elseif event == "terminate" then
    break
  end
end
