-------------------------------------------------
-- ATM10 Colony Manager Startup
-------------------------------------------------

local PROGRAM = "colony_manager.lua"

if not fs.exists(PROGRAM) then
    print("ERROR: "..PROGRAM.." not found")
    print("Place colony_manager.lua on this computer.")
    return
end


print("Starting ATM10 Colony Manager...")

sleep(2)

shell.run(PROGRAM)