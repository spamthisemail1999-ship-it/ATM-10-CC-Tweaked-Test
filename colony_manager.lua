-------------------------------------------------
-- ATM10 MineColonies AE2 Manager
-------------------------------------------------
print("v1.0.4")
dofile("config.lua")


-------------------------------------------------
-- PERIPHERALS
-------------------------------------------------

local me = peripheral.wrap("me_bridge_2")
local colony = peripheral.wrap("colony_integrator_0")
local chat = peripheral.wrap("chat_box_1")
local monitor = peripheral.find("monitor")


if not me then
    error("ME Bridge not found")
end


if not colony then
    error("Colony Integrator not found")
end


-------------------------------------------------
-- STATUS
-------------------------------------------------

local delivered = 0
local errors = 0
local requestsWaiting = 0

local status = "Starting"
local lastAction = "None"



-------------------------------------------------
-- MONITOR
-------------------------------------------------

local function updateMonitor()

    if not monitor then
        return
    end


    monitor.clear()

    monitor.setCursorPos(1,1)
    monitor.write("ATM10 COLONY MANAGER")


    monitor.setCursorPos(1,3)
    monitor.write("Status: "..status)


    monitor.setCursorPos(1,4)
    monitor.write("Requests: "..requestsWaiting)


    monitor.setCursorPos(1,5)
    monitor.write("Delivered: "..delivered)


    monitor.setCursorPos(1,6)
    monitor.write("Errors: "..errors)


    monitor.setCursorPos(1,8)
    monitor.write("Last:")


    monitor.setCursorPos(1,9)
    monitor.write(
        string.sub(lastAction,1,30)
    )

end



-------------------------------------------------
-- NOTIFY
-------------------------------------------------

local function notify(message)

    print(message)

    lastAction = message

    updateMonitor()


    if CONFIG.CHAT_ENABLED and chat then

        pcall(function()

            chat.sendMessage(
                "[AE2 Colony] "..message
            )

        end)

    end

end



-------------------------------------------------
-- AE2 CHECK
-------------------------------------------------

local function getStored(item)

    print("Checking AE2 for:", item)


    local success,data =
        pcall(function()

            return me.getItem({
                name=item
            })

        end)



    print("API success:", success)


    if data then

        print("AE2 count:", data.count)

    else

        print("AE2 returned nil")

    end



    if success and data then

        return data.count or 0

    end


    return 0

end



-------------------------------------------------
-- CRAFT
-------------------------------------------------

local function craft(item,count)


    if not me.isCraftable({
        name=item
    }) then


        notify(
            "Cannot craft "..item
        )


        errors = errors + 1

        return false

    end



    notify(
        "Crafting "..item.." x"..count
    )


    local success,result =
        pcall(function()

            return me.craftItem(
                {
                    name=item,
                    count=count
                }
            )

        end)



    return success and result

end



-------------------------------------------------
-- EXPORT
-------------------------------------------------

local function export(item,count)


    local success,moved =
        pcall(function()

            return me.exportItem(
                {
                    name=item
                },
                CONFIG.EXPORT_SIDE,
                count
            )

        end)



    if not success then

        print(
            "Export error:",
            moved
        )

        return false

    end



    print(
        "Export moved:",
        moved
    )


    return moved and moved > 0

end



-------------------------------------------------
-- PROCESS REQUEST
-------------------------------------------------

local function processRequest(request)


    print(
        textutils.serialize(request)
    )



    local item =
        request.name



    if not item then

        print("No item name found")

        return

    end



    local amount =
        request.count or 1



    notify(
        "Processing "..item.." x"..amount
    )



    local stored =
        getStored(item)



    print(
        "AE2 has",
        stored,
        "of",
        item
    )



    if stored < amount then


        local missing =
            amount - stored


        craft(
            item,
            missing
        )


        sleep(5)

    end



    if export(item,amount) then


        delivered =
            delivered + 1


        notify(
            "Delivered "..item
        )


    else


        errors =
            errors + 1


        notify(
            "Failed "..item
        )

    end

end




-------------------------------------------------
-- MAIN
-------------------------------------------------

notify(
    "Manager online"
)


while true do


    local success,requests =
        pcall(function()

            return colony.getRequests()

        end)



    if success and requests then


        requestsWaiting =
            #requests



        for _,request in pairs(requests) do


            processRequest(request)


            sleep(0)

        end


    else


        errors =
            errors + 1


        notify(
            "Failed reading colony requests"
        )


    end



    status =
        "Running"


    updateMonitor()



    sleep(
        CONFIG.CHECK_INTERVAL
    )

end