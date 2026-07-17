-------------------------------------------------
-- ATM10 MineColonies AE2 Manager
-- Advanced Peripherals
-------------------------------------------------

dofile("config.lua")


-------------------------------------------------
-- PERIPHERALS
-------------------------------------------------

local me =
    peripheral.wrap("me_bridge_2")


local colony =
    peripheral.wrap("colony_integrator_0")


local chat =
    peripheral.wrap("chat_box_1")


local monitor =
    peripheral.find("monitor")



if not me then
    error("ME Bridge missing")
end


if not colony then
    error("Colony Integrator missing")
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


    local width,height =
        monitor.getSize()


    monitor.clear()


    monitor.setCursorPos(1,1)

    monitor.write(
        "ATM10 COLONY MANAGER"
    )


    monitor.setCursorPos(1,3)

    monitor.write(
        "Status: "..status
    )


    monitor.setCursorPos(1,4)

    monitor.write(
        "Requests: "..requestsWaiting
    )


    monitor.setCursorPos(1,5)

    monitor.write(
        "Delivered: "..delivered
    )


    monitor.setCursorPos(1,6)

    monitor.write(
        "Errors: "..errors
    )


    monitor.setCursorPos(1,8)

    monitor.write(
        "Last Action:"
    )


    monitor.setCursorPos(1,9)

    monitor.write(
        string.sub(lastAction,1,width)
    )

end



-------------------------------------------------
-- CHAT
-------------------------------------------------

local function notify(message)

    print(message)


    lastAction =
        message


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
-- AE2 ITEM CHECK
-------------------------------------------------

local function getStored(item)


    local success,data =
        pcall(function()

            return me.getItem({
                name=item
            })

        end)



    if success and data then

        return data.count or 0

    end


    return 0

end




-------------------------------------------------
-- CRAFT
-------------------------------------------------

local function craft(item,count)


    local canCraft =
        me.isCraftable({
            name=item
        })



    if not canCraft then

        notify(
            "Cannot craft "..item
        )

        errors =
            errors + 1

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
                })

        end)



    return success and result

end




-------------------------------------------------
-- EXPORT
-------------------------------------------------

local function export(item,count)


    local moved =
        me.exportItem(
            {
                name=item
            },
            CONFIG.EXPORT_SIDE,
            count
        )



    return moved > 0

end




-------------------------------------------------
-- PROCESS REQUEST
-------------------------------------------------

local function processRequest(request)


    if not request.item then
        return
    end



    local item =
        request.item.name


    local amount =
        request.count



    notify(
        "Processing "..item.." x"..amount
    )



    local stored =
        getStored(item)



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
-- COMMAND LISTENER
-------------------------------------------------

local function commandListener()


    while true do


        local event,command =
            os.pullEvent("shell_command")



        if command ==
            "colony_reload" then


            shell.run(
                "colony_manager.lua"
            )

            return

        end


    end

end





-------------------------------------------------
-- START COMMAND LISTENER
-------------------------------------------------

parallel.waitForAny(

    commandListener,

    function()


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



                local processed = 0



                for _,request in pairs(requests) do


                    processRequest(request)


                    processed =
                        processed + 1



                    sleep(0)



                    if processed >= CONFIG.MAX_REQUESTS_PER_CYCLE then
                        break
                    end


                end


            else


                errors =
                    errors + 1


                notify(
                    "Request scan failed"
                )


            end



            status =
                "Running"


            updateMonitor()



            sleep(
                CONFIG.CHECK_INTERVAL
            )


        end

    end

)