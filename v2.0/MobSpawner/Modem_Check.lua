-- Modem compatibility check
print("Checking rednet support...")

if not rednet then
  print("rednet is not available")
  return
end

print("rednet is available")

local modemSide = "right"
if not peripheral.isPresent(modemSide) then
  print("No peripheral on side: " .. modemSide)
  return
end

print("Peripheral found on side: " .. modemSide)
print("Peripheral type: " .. peripheral.getType(modemSide))

local ok, err = pcall(function()
  rednet.open(modemSide)
end)

if ok then
  print("rednet.open succeeded")
  print("isOpen = " .. tostring(rednet.isOpen(modemSide)))
else
  print("rednet.open failed")
  print(err)
end
