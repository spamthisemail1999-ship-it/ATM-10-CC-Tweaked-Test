-- Colony_Manager.lua


dofile("config.lua")



local me =
peripheral.find("meBridge")


local colony =
peripheral.find("colonyIntegrator")


local chat =
peripheral.find("chatBox")


local monitor =
peripheral.find("monitor")



if not me then
    error("ME Bridge missing")
end


if not colony then
    error("Colony Integrator missing")
end



------------------------------------------------
-- DATA
------------------------------------------------

local completed = {}

local failed = {}

local activeCrafts = {}

local delivered = 0




------------------------------------------------
-- CHAT
------------------------------------------------

local function message(text)

    print(text)


    if CONFIG.CHAT and chat then

        chat.sendMessage(
            "[AE2 Colony] "..text
        )

    end

end




------------------------------------------------
-- MONITOR
------------------------------------------------

local function display()

    if not CONFIG.MONITOR then
        return
    end


    if not monitor then
        return
    end


    monitor.clear()


    monitor.setCursorPos(1,1)

    monitor.write(
        "ATM10 AE2 Colony Manager"
    )


    monitor.setCursorPos(1,3)

    monitor.write(
        "Delivered: "..delivered
    )


    monitor.setCursorPos(1,4)

    monitor.write(
        "Tracked: "..#completed
    )

end




------------------------------------------------
-- AE2 STORAGE
------------------------------------------------

local function amount(item)

    local result =
    me.getItemAmount(
        {
            name=item
        })


    return result or 0

end




------------------------------------------------
-- CRAFTING
------------------------------------------------

local function craft(item,count)


    if CONFIG.BLACKLIST[item] then

        return false

    end



    if activeCrafts[item] then

        return false

    end



    activeCrafts[item]=true



    message(
        "Crafting "..item.." x"..count
    )



    local success =
    me.craftItem(
        {
            name=item,
            count=count
        })



    sleep(CONFIG.CRAFT_DELAY)


    activeCrafts[item]=nil



    return success

end





------------------------------------------------
-- EXPORT
------------------------------------------------

local function export(item,count)



    local stored =
    amount(item)



    if stored < count then


        local missing =
        count-stored


        craft(
            item,
            missing
        )


        sleep(5)

    end




    local result =
    me.exportItem(
        {
            name=item
        },
        count,
        CONFIG.EXPORT_SIDE
    )


    return result

end





------------------------------------------------
-- STOCK CHECK
------------------------------------------------

local function maintainStock()


    for item,target in pairs(CONFIG.STOCK) do


        local current =
        amount(item)



        if current < target then


            local missing =
            target-current



            message(
                "Restocking "..item..
                " +"..missing
            )


            craft(
                item,
                missing
            )


        end

    end

end





------------------------------------------------
-- REQUEST HANDLER
------------------------------------------------

local function process(request)



    local item =
    request.item.name


    local count =
    request.count



    local id =
    item..":"..count




    if completed[id] then

        return

    end




    message(
        "Request "..item..
        " x"..count
    )




    if export(item,count) then


        completed[id]=true


        delivered =
        delivered+1



        message(
            "Delivered "..item
        )


    else


        failed[id]=true


        message(
            "FAILED "..item
        )


    end


end





------------------------------------------------
-- MAIN LOOP
------------------------------------------------


message(
    "Controller started"
)



while true do



    local success,requests =
    pcall(
        colony.getRequests
    )



    if success then


        for _,request in pairs(requests) do


            process(request)


        end


    else


        message(
            "Colony scan failed"
        )

    end




    maintainStock()



    display()



    sleep(
        CONFIG.CHECK_INTERVAL
    )


end