-------------------------------------------------
-- ATM10 MineColonies AE2 Manager
-- Advanced Peripherals API
-------------------------------------------------

dofile("config.lua")


-------------------------------------------------
-- PERIPHERALS
-------------------------------------------------
local monitor = peripheral.find("monitor")

local status = "Starting..."
local lastAction = "None"
local requestCount = 0

local me =
    peripheral.wrap("me_bridge_2")

local colony =
    peripheral.wrap("colony_integrator_0")

local chat =
    peripheral.wrap("chat_box_1")



if not me then
    error("ME Bridge missing")
end


if not colony then
    error("Colony Integrator missing")
end



-------------------------------------------------
-- VARIABLES
-------------------------------------------------

local completed = {}

local delivered = 0



-------------------------------------------------
-- CHAT
-------------------------------------------------

local function notify(message)

    print(message)

    if CONFIG.CHAT_ENABLED and chat then

        pcall(function()
            chat.sendMessage(
                "[AE2 Colony] "..message
            )
        end)

    end
end



-------------------------------------------------
-- AE2 ITEM COUNT
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


    local craftable =
        me.isCraftable({
            name=item
        })


    if not craftable then

        notify(
            "Cannot craft "..item
        )

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
-- HANDLE REQUEST
-------------------------------------------------

local function processRequest(request)


    if not request.item then
        return
    end


    local item =
        request.item.name


    local amount =
        request.count



    local id =
        item..":"..amount



    if completed[id] then
        return
    end



    notify(
        "Request "..item.." x"..amount
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




    local success =
        export(
            item,
            amount
        )



    if success then


        completed[id]=true

        delivered =
            delivered + 1


        notify(
            "Delivered "..item
        )


    else

        notify(
            "Failed delivery "..item
        )

    end

end




-------------------------------------------------
-- MAIN LOOP
-------------------------------------------------

notify(
    "Colony manager online"
)



while true do


    local success,requests =
        pcall(function()

            return colony.getRequests()

        end)



    if success and requests then


        local processed = 0



        for _,request in pairs(requests) do


            processRequest(request)


            processed =
                processed + 1



            -- force ComputerCraft yield
            sleep(0)



            if processed >= CONFIG.MAX_REQUESTS_PER_CYCLE then
                break
            end

        end

    else

        notify(
            "Failed reading colony requests"
        )

    end



    sleep(
        CONFIG.CHECK_INTERVAL
    )

end