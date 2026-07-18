-------------------------------------------------
-- ATM10 Colony Manager Configuration
-------------------------------------------------

CONFIG = {}


-------------------------------------------------
-- VERSION
-------------------------------------------------

CONFIG.VERSION = "2.0"


-------------------------------------------------
-- GENERAL SETTINGS
-------------------------------------------------

-- Time between MineColonies scans (seconds)
CONFIG.CHECK_INTERVAL = 10


-- Side where the delivery inventory is located
-- Your confirmed setup uses "down"
CONFIG.EXPORT_SIDE = "down"



-------------------------------------------------
-- CHAT SETTINGS
-------------------------------------------------

CONFIG.CHAT_ENABLED = true


-- Prevents chat spam
-- Minimum seconds between repeated messages
CONFIG.CHAT_COOLDOWN = 15



-------------------------------------------------
-- MONITOR SETTINGS
-------------------------------------------------

CONFIG.MONITOR_ENABLED = true

CONFIG.MONITOR_REFRESH = 5



-------------------------------------------------
-- DEBUG / LOGGING
-------------------------------------------------

CONFIG.DEBUG = false


-- Saves logs to this file
CONFIG.LOG_FILE = "colony_manager.log"



-------------------------------------------------
-- REQUEST SETTINGS
-------------------------------------------------

-- Maximum requests handled per scan
CONFIG.MAX_REQUESTS_PER_SCAN = 20


-- Prevents duplicate processing
CONFIG.REQUEST_CACHE_TIME = 3600



-------------------------------------------------
-- CRAFTING SETTINGS
-------------------------------------------------

-- Automatically craft missing items
CONFIG.AUTO_CRAFT = true


-- Seconds to wait for AE2 crafting jobs
CONFIG.CRAFT_WAIT_TIME = 10


-- Maximum time a craft can take before retrying
CONFIG.CRAFT_TIMEOUT = 300



-------------------------------------------------
-- DELIVERY SETTINGS
-------------------------------------------------

-- Export multiple requests for the same building together
CONFIG.BATCH_DELIVERIES = true


-- Keep a history of completed deliveries
CONFIG.HISTORY_SIZE = 15



-------------------------------------------------
-- PRIORITY SYSTEM
-------------------------------------------------

-- Higher entries are processed first.
-- Names must match MineColonies request targets.

CONFIG.PRIORITY = {

    "Builder's Hut",

    "Courier's Hut",

    "Warehouse",

    "Blacksmith's Hut",

    "Mechanic's Hut",

    "Sawmill",

    "Stone Smeltery",

    "Composter",

    "Farmer's Hut"

}



-------------------------------------------------
-- DEFAULT VALUES
-------------------------------------------------

CONFIG.UNKNOWN_PRIORITY = 999


-------------------------------------------------
-- STATISTICS
-------------------------------------------------

CONFIG.STATS_ENABLED = true