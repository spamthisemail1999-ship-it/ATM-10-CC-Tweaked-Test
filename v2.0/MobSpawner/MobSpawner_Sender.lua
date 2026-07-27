-- Main control computer
-- Sends one wireless message per spawner over its own channel.

local modemSide = "right"
local baseChannel = 1000

if not rednet then
  print("This requires ComputerCraft rednet support")
  return
end

if not peripheral.isPresent(modemSide) then
  print("No modem on the " .. modemSide .. " side")
  return
end

rednet.open(modemSide)
print("MobSpawner sender ready")
print("Use: sender 1 true")
print("Use: sender 2 false")

while true do
  local event, p1, p2, p3, p4, p5 = os.pullEvent()
  if event == "key" then
    -- This simple version is meant to be driven by a program that calls sendSpawner(index, state)
    -- You can wire this into your monitor UI later.
  elseif event == "term" then
    break
  end
end

function sendSpawner(index, state)
  local channel = baseChannel + index
  rednet.send(channel, { spawner = index, state = state })
  print("Sent spawner " .. index .. " -> " .. tostring(state) .. " on channel " .. channel)
end
