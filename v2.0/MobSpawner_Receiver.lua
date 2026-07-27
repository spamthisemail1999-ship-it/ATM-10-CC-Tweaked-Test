-- Spawner computer receiver
-- Listens on one channel for its own spawner only.

local modemSide = "right"
local spawnerId = 1
local channel = 1000 + spawnerId
local outputSide = "back"

if not rednet then
  print("This requires ComputerCraft rednet support")
  return
end

if not peripheral.isPresent(modemSide) then
  print("No modem on the " .. modemSide .. " side")
  return
end

rednet.open(modemSide)
print("Receiver ready for spawner " .. spawnerId .. " on channel " .. channel)

while true do
  local sender, message = rednet.receive(channel)
  if message and message.spawner == spawnerId then
    redstone.setOutput(outputSide, message.state)
    print("Spawner " .. spawnerId .. " set to " .. tostring(message.state))
  end
end
