-------------------------------------------------
-- ATM10 Colony Manager
-- Advanced Peripherals + AE2 + MineColonies
--
-- Version: 2.0
-------------------------------------------------


-------------------------------------------------
-- LOAD CONFIG
-------------------------------------------------

if not fs.exists("config.lua") then
    error("Missing config.lua")
end


dofile("config.lua")



-------------------------------------------------
-- GLOBAL STATE
-------------------------------------------------

local VERSION = CONFIG.VERSION


local STATE = {

    running = true,

    startTime = os.clock(),

    requestsProcessed = 0,

    requestsDelivered = 0,

    requestsFailed = 0,

    itemsExported = 0,

    itemsCrafted = 0,

    activeRequests = 0,

    lastAction = "Starting",

    lastError = "None",

    history = {},

}



-------------------------------------------------
-- PERIPHERALS
-------------------------------------------------

local PERIPHERALS = {

    me = nil,

    colony = nil,

    chat = nil,

    monitor = nil,

}



-------------------------------------------------
-- CONNECT PERIPHERALS
-------------------------------------------------

local function connectPeripherals()


    print("Connecting peripherals...")


    PERIPHERALS.me =
        peripheral.wrap("me_bridge_2")


    PERIPHERALS.colony =
        peripheral.wrap("colony_integrator_0")


    PERIPHERALS.chat =
        peripheral.wrap("chat_box_1")


    if CONFIG.MONITOR_ENABLED then

        PERIPHERALS.monitor =
            peripheral.find("monitor")

    end



    if not PERIPHERALS.me then

        error(
            "ME Bridge not found"
        )

    end



    if not PERIPHERALS.colony then

        error(
            "Colony Integrator not found"
        )

    end



    print("ME Bridge: OK")

    print("Colony Integrator: OK")



    if PERIPHERALS.chat then

        print("Chat Box: OK")

    else

        print("Chat Box: Missing")

    end



    if PERIPHERALS.monitor then

        print("Monitor: OK")

    else

        print("Monitor: Missing")

    end


end



-------------------------------------------------
-- LOGGER
-------------------------------------------------

local function log(message)


    local line =
        "["..
        os.date("%H:%M:%S")..
        "] "..
        message



    print(line)



    if CONFIG.LOG_FILE then

        local file =
            fs.open(
                CONFIG.LOG_FILE,
                "a"
            )


        if file then

            file.writeLine(line)

            file.close()

        end

    end


end



local function debug(message)


    if CONFIG.DEBUG then

        log(
            "[DEBUG] "..message
        )

    end


end



-------------------------------------------------
-- CHAT SYSTEM
-------------------------------------------------

local lastChat = {}



local function sendChat(message)


    if not CONFIG.CHAT_ENABLED then

        return

    end



    if not PERIPHERALS.chat then

        return

    end



    local now =
        os.clock()



    if lastChat[message]
    and
    now - lastChat[message]
        < CONFIG.CHAT_COOLDOWN
    then

        return

    end



    lastChat[message] = now



    pcall(function()

        PERIPHERALS.chat.sendMessage(
            "[Colony Manager] "..message
        )

    end)


end



-------------------------------------------------
-- MONITOR SYSTEM
-------------------------------------------------

local function clearMonitor()


    local m =
        PERIPHERALS.monitor


    if not m then

        return

    end



    m.clear()

    m.setCursorPos(1,1)


end




local function writeMonitor(line,text)


    local m =
        PERIPHERALS.monitor


    if not m then

        return

    end



    m.setCursorPos(
        1,
        line
    )


    m.clearLine()


    m.write(text)


end




local function updateMonitor()


    local m =
        PERIPHERALS.monitor


    if not m then

        return

    end



    clearMonitor()



    writeMonitor(
        1,
        "ATM10 Colony Manager v"..VERSION
    )


    writeMonitor(
        3,
        "Status: ONLINE"
    )


    writeMonitor(
        4,
        "Processed: "..STATE.requestsProcessed
    )


    writeMonitor(
        5,
        "Delivered: "..STATE.requestsDelivered
    )


    writeMonitor(
        6,
        "Failed: "..STATE.requestsFailed
    )


    writeMonitor(
        8,
        "Last:"
    )


    writeMonitor(
        9,
        string.sub(
            STATE.lastAction,
            1,
            30
        )
    )


end



-------------------------------------------------
-- STATISTICS
-------------------------------------------------

local function addHistory(entry)


    table.insert(
        STATE.history,
        1,
        entry
    )



    while #STATE.history >
        CONFIG.HISTORY_SIZE
    do

        table.remove(
            STATE.history
        )

    end


end



-------------------------------------------------
-- INITIALIZE
-------------------------------------------------

connectPeripherals()


updateMonitor()


log(
    "ATM10 Colony Manager started"
)


sendChat(
    "Manager online"
)

-------------------------------------------------
-- REQUEST MANAGEMENT
-------------------------------------------------

local REQUEST_CACHE = {}

local REQUEST_QUEUE = {}



-------------------------------------------------
-- PRIORITY LOOKUP
-------------------------------------------------

local function getPriority(target)


    for index,name in ipairs(CONFIG.PRIORITY) do


        if name == target then

            return index

        end


    end



    return CONFIG.UNKNOWN_PRIORITY

end




-------------------------------------------------
-- REQUEST CACHE
-------------------------------------------------

local function isProcessed(id)


    if REQUEST_CACHE[id] then

        local age =
            os.clock()
            -
            REQUEST_CACHE[id]


        if age <
            CONFIG.REQUEST_CACHE_TIME
        then

            return true

        end


    end



    return false

end




local function markProcessed(id)


    REQUEST_CACHE[id] =
        os.clock()


end




local function cleanCache()


    local now =
        os.clock()



    for id,time in pairs(REQUEST_CACHE) do


        if now - time >
            CONFIG.REQUEST_CACHE_TIME
        then

            REQUEST_CACHE[id] = nil

        end


    end


end




-------------------------------------------------
-- REQUEST PARSER
-------------------------------------------------

local function parseRequest(request)


    -- MineColonies request objects
    -- use items[1].name for registry ID
    --
    -- Example:
    --
    -- request.items[1].name
    -- minecraft:redstone_block
    --


    if not request.items
    or not request.items[1]
    then

        debug(
            "Invalid request"
        )

        return nil

    end



    local item =
        request.items[1].name



    local count =
        request.items[1].count
        or request.count
        or 1



    if not item then

        return nil

    end



    return {


        id = request.id,

        item = item,

        count = count,

        target = request.target
        or "Unknown",


        priority =
            getPriority(
                request.target
            ),


        raw = request,


    }


end




-------------------------------------------------
-- SORT REQUESTS
-------------------------------------------------

local function sortRequests(a,b)


    if a.priority == b.priority then


        return a.id < b.id


    end



    return a.priority < b.priority


end




-------------------------------------------------
-- LOAD REQUEST QUEUE
-------------------------------------------------

local function updateRequestQueue()


    debug(
        "Updating request queue"
    )



    cleanCache()



    local success,requests =
        pcall(function()


            return
            PERIPHERALS.colony.getRequests()


        end)



    if not success then


        STATE.lastError =
            "Unable to read colony requests"


        log(
            STATE.lastError
        )


        return

    end



    REQUEST_QUEUE = {}



    for _,request in pairs(requests) do


        if not isProcessed(request.id) then


            local parsed =
                parseRequest(request)



            if parsed then


                table.insert(
                    REQUEST_QUEUE,
                    parsed
                )


            end


        end


    end



    table.sort(
        REQUEST_QUEUE,
        sortRequests
    )



    STATE.activeRequests =
        #REQUEST_QUEUE



    debug(
        "Queue size: "
        ..
        #REQUEST_QUEUE
    )


end




-------------------------------------------------
-- GET NEXT REQUEST
-------------------------------------------------

local function getNextRequest()


    return
    table.remove(
        REQUEST_QUEUE,
        1
    )


end

-------------------------------------------------
-- AE2 MANAGEMENT
-------------------------------------------------


local function getStored(item)


    debug(
        "Checking AE2: "..item
    )



    local success,result =
        pcall(function()


            return
            PERIPHERALS.me.getItem({
                name = item
            })


        end)



    if not success then


        log(
            "AE2 lookup failed: "
            ..
            tostring(result)
        )


        return 0

    end



    if not result then

        return 0

    end



    return
    result.count
    or 0


end





-------------------------------------------------
-- CRAFTING
-------------------------------------------------


local function canCraft(item)


    local success,result =
        pcall(function()


            return
            PERIPHERALS.me.isCraftable({
                name = item
            })


        end)



    if not success then

        return false

    end



    return result == true


end





local function craftItem(item,count)


    if not CONFIG.AUTO_CRAFT then

        return false

    end



    if not canCraft(item) then


        debug(
            "Not craftable: "..item
        )


        return false

    end



    log(
        "Crafting "
        ..
        item
        ..
        " x"
        ..
        count
    )



    local success,result =
        pcall(function()


            return
            PERIPHERALS.me.craftItem({
                name = item,
                count = count
            })


        end)



    if success and result then


        STATE.itemsCrafted =
            STATE.itemsCrafted
            +
            count



        return true


    end



    return false


end





-------------------------------------------------
-- EXPORT SYSTEM
-------------------------------------------------


local function exportItem(item,count)


    debug(
        "Exporting "
        ..
        item
    )



    local success,moved =
        pcall(function()


            return
            PERIPHERALS.me.exportItem(
                {
                    name = item
                },
                CONFIG.EXPORT_SIDE,
                count
            )


        end)



    if not success then


        log(
            "Export error: "
            ..
            tostring(moved)
        )


        return false,0


    end



    moved =
        moved or 0



    STATE.itemsExported =
        STATE.itemsExported
        +
        moved



    return
        moved > 0,
        moved


end





-------------------------------------------------
-- PROCESS DELIVERY
-------------------------------------------------


local function processDelivery(request)


    local item =
        request.item


    local count =
        request.count



    STATE.lastAction =
        item
        ..
        " x"
        ..
        count



    updateMonitor()



    log(
        "Processing "
        ..
        item
        ..
        " x"
        ..
        count
    )



    local stored =
        getStored(item)



    debug(
        "Stored: "
        ..
        stored
    )



    if stored < count then


        local needed =
            count - stored



        local crafted =
            craftItem(
                item,
                needed
            )



        if crafted then


            sleep(
                CONFIG.CRAFT_WAIT_TIME
            )


        end


    end




    local success,moved =
        exportItem(
            item,
            count
        )



    if success then


        STATE.requestsDelivered =
            STATE.requestsDelivered
            +
            1



        STATE.requestsProcessed =
            STATE.requestsProcessed
            +
            1



        markProcessed(
            request.id
        )



        addHistory({

            item = item,

            count = moved,

            target = request.target,

            time = os.date("%H:%M:%S")

        })



        sendChat(
            "Delivered "
            ..
            item
            ..
            " x"
            ..
            moved
        )



        log(
            "Delivery complete"
        )



    else


        STATE.requestsFailed =
            STATE.requestsFailed
            +
            1



        log(
            "Delivery failed: "
            ..
            item
        )


    end



end

-------------------------------------------------
-- MAIN LOOP
-------------------------------------------------


local function shutdown()


    STATE.running = false


    log(
        "Colony Manager shutting down"
    )


    sendChat(
        "Manager offline"
    )


    updateMonitor()


end





-------------------------------------------------
-- ERROR HANDLER
-------------------------------------------------


local function safeRun(functionToRun)


    local success,errorMessage =
        pcall(functionToRun)



    if not success then


        STATE.lastError =
            tostring(errorMessage)



        log(
            "ERROR: "
            ..
            STATE.lastError
        )



        STATE.requestsFailed =
            STATE.requestsFailed
            +
            1


    end



end





-------------------------------------------------
-- STARTUP COMPLETE
-------------------------------------------------


log(
    "ATM10 Colony Manager v"
    ..
    VERSION
    ..
    " running"
)


sendChat(
    "Colony Manager active"
)



-------------------------------------------------
-- PROGRAM LOOP
-------------------------------------------------


while STATE.running do


    safeRun(function()


        updateRequestQueue()



        local processed = 0



        while #REQUEST_QUEUE > 0
        and processed < CONFIG.MAX_REQUESTS_PER_SCAN
        do


            local request =
                getNextRequest()



            if request then


                processDelivery(
                    request
                )


                processed =
                    processed + 1


            end


        end



        updateMonitor()



    end)



    sleep(
        CONFIG.CHECK_INTERVAL
    )


end