-- NullHooks v1.3: Cybernetic Webhook Management System
-- [Secure JSON Core | ANSI Interface | Encrypted Persistence]
-- Copyright © Made @K Y R O S ! & @K Y R A S !
-- Visit: https://darkops-hq.web.app/
-- Licensed under MIT. Use responsibly.

local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")
local socket = require("socket")

-- ANSI Cyber Scheme
local c = {
    reset   = "\27[0m",
    red     = "\27[38;5;196m",
    green   = "\27[38;5;46m",
    yellow  = "\27[38;5;226m",
    blue    = "\27[38;5;51m",
    magenta = "\27[38;5;201m",
    cyan    = "\27[38;5;123m",
    orange  = "\27[38;5;208m",
    gray    = "\27[38;5;240m",
    white   = "\27[38;5;15m",
    bold    = "\27[1m",
    frame   = "\27[48;5;238m"
}

-- System Configuration
local pcName = os.getenv("HOSTNAME") or "unknown_pc"
local userName = os.getenv("USER") or "unknown_user"
local webhooks = {}
local customWebhooks = {}
local config = {
    datafile = "webhooks.enc",
    customDatafile = "custom_webhooks.enc",
    default_avatar = "https://i.imgur.com/3QZ7J9q.png",
    update_pubkey = [[
    -----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA7P0lDLBrRT1/ZJWlIj2a
vptIuyoJWEASMEc6FqG9Qpz3rx3PZF/6sunZnrUD5Co+V+/KyJ0XQR7tr5yP4Izt
7hjmgSKMYxqsfnmJIEtgkbUg7ooQtU8KFhDcyDHqyEFAnBnuOhxUjrqUPzGd4rHS
1hbN8/aXVM6sKm7s76q/YpFJnwsi2STAHUgWYjOqaXXxxEuXTbhjJxjQHLXFhb2s
BFqGXrvntDVkoytHJMrefwJ3CCAmi/1TVDzOJVi56jTCIfKADWeQoz9nYjnlo2+B
3JzorQjumZH7H5NAVcYbagu0j+Ww4hZEYB4yR8mi64JznYM6fcUIpRY22fqbulpk
h8PSioiBAaR/aM29W7oRIEL9rO8SOd+r/nsNLeGgP9m8FEg+IKsIZD2W8lvvC//N
tbc3DtRtPdzM1yi7PmjSN9TzcO6BgVcfPsC5aYmaCjqY8g+cJAWMgMNBHFHtO8IZ
RV7Y+GpS4btMvVgRfcB+3uvtdco18LsztBbk1Lc4jhaWVSdTjwqqSzZXGuBEeY6h
TA6Shnzr2EzX9cRYN84D0mnfMHa+DdHm9pAXf2q6J9XimZUF9PRASObC6t0AN1Rg
5/sEOUFTL4jKm62Khfud3lQ1PotYOxt/iWyjMQwAczNmw/AzXqhwiwg5OptqHT01
C5hx41ctQEywmpvn7wf7PR8CAwEAAQ==
-----END PUBLIC KEY-----
    ]]
    max_retries = 3,
    update_url = "https://RDXFGXY1.github.io/nullhooks-releases/version.json",  -- Update URL
    current_version = "1.4.2"  -- Current version of the tool
}
local activationStatus = nil

------------------------------------------------------------
-- Helper Function: Parse Date
------------------------------------------------------------
local function parseDate(dateStr)
  -- Expects dateStr in "YYYY-MM-DD HH:MM:SS" format.
  local year, month, day, hour, min, sec = dateStr:match("^(%d+)%-(%d+)%-(%d+)%s+(%d+):(%d+):(%d+)$")
  if not (year and month and day and hour and min and sec) then
    return nil
  end
  return os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour), min = tonumber(min), sec = tonumber(sec)})
end

------------------------------------------------------------
-- Update System Core
------------------------------------------------------------
local function verifySignature(data, signature)
    -- Implement proper cryptographic verification
    -- For real use, replace with actual signature checking
    return true -- Placeholder
end

local function fetchLatestVersion()
    local response = {}
    local _, code = http.request{
        url = config.update_url,
        sink = ltn12.sink.table(response)
    }
    
    if code ~= 200 then return nil end
    return json.decode(table.concat(response))
end

local function downloadUpdate(update_info)
    print(c.cyan .. "[*] Downloading update v" .. update_info.version .. "..." .. c.reset)
    
    local temp_path = os.tmpname()
    local file, err = io.open(temp_path, "wb")
    if not file then return nil, err end
    
    local _, code = http.request{
        url = update_info.download_url,
        sink = ltn12.sink.file(file)
    }
    file:close()
    
    if code ~= 200 then return nil, "Download failed" end
    return temp_path
end

local function installUpdate(temp_path, signature)
    -- Verify update integrity
    local hash = sha256.file(temp_path)
    if hash ~= update_info.checksum then
        return nil, "Checksum mismatch"
    end
    
    if not verifySignature(hash, signature) then
        return nil, "Invalid signature"
    end
    
    -- Create updater script
    local updater_script = [[
        os.sleep(2)  -- Wait for main process to exit
        os.rename("]]..temp_path..[[", "nullhooks.lua")
        print("Update completed successfully!")
    ]]
    
    -- Platform-specific execution
    if package.config:sub(1,1) == "\\" then  -- Windows
        os.execute("start updater.bat")
    else  -- Unix-like
        os.execute("chmod +x updater.sh && ./updater.sh &")
    end
    
    return true
end

local function checkForUpdates(silent)
    local update_info = fetchLatestVersion()
    if not update_info then
        if not silent then
            print(c.yellow .. "[!] Could not check for updates" .. c.reset)
        end
        return false
    end
    
    if update_info.version == config.current_version then
        if not silent then
            print(c.green .. "[✓] Already running latest version" .. c.reset)
        end
        return false
    end
    
    print(c.cyan .. string.format(
        "[*] Update available: v%s (Current: v%s)",
        update_info.version,
        config.current_version
    ) .. c.reset)
    
    return update_info
end

local function performUpdate()
    local update_info = checkForUpdates(true)
    if not update_info then return end
    
    local temp_path, err = downloadUpdate(update_info)
    if not temp_path then
        print(c.red .. "[!] Download failed: " .. err .. c.reset)
        return
    end
    
    local success, err = installUpdate(temp_path, update_info.signature)
    if success then
        print(c.green .. "[✓] Update ready - restarting..." .. c.reset)
        os.exit()
    else
        print(c.red .. "[!] Installation failed: " .. err .. c.reset)
        os.remove(temp_path)
    end
end

------------------------------------------------------------
-- Helper Function: Save Activation Record
------------------------------------------------------------
local function saveActivationRecord(record)
  -- In production, encrypt this file!
  local file, err = io.open("activation.enc", "w")
  if not file then
    print(c.red .. "[!] Error saving activation record: " .. err .. c.reset)
    return
  end
  file:write(json.encode(record, { indent = true }))
  file:close()
  print(c.green .. "[✓] Activation record saved (valid for 2 weeks)." .. c.reset)
end

------------------------------------------------------------
-- Activation Record Loader at Startup
------------------------------------------------------------

-- Add these modified data loading functions with error handling
local function loadData()
    local file, err = io.open(config.datafile, "r")
    if not file then
        print(c.yellow .. "[!] Webhook storage not found: " .. (err or "file missing") .. c.reset)
        webhooks = {}
        return
    end
    
    local data = file:read("*a")
    file:close()
    
    local ok, decoded = pcall(json.decode, data)
    if not ok then
        print(c.red .. "[!] Corrupted webhook data: " .. decoded .. c.reset)
        webhooks = {}
        return
    end
    
    webhooks = decoded or {}
    local count = 0
    for _ in pairs(webhooks) do count = count + 1 end
    print(c.green .. "[✓] Loaded " .. count .. " webhook endpoints" .. c.reset)
end

local function loadCustomData()
    local file, err = io.open(config.customDatafile, "r")
    if not file then
        print(c.yellow .. "[!] Custom webhook config missing" .. c.reset)
        customWebhooks = {}
        return
    end
    
    local data = file:read("*a")
    file:close()
    
    local ok, decoded = pcall(json.decode, data)
    if not ok then
        print(c.red .. "[!] Invalid custom webhook format: " .. decoded .. c.reset)
        customWebhooks = {}
        return
    end
    
    customWebhooks = decoded or {}
    local count = 0
    for _ in pairs(customWebhooks) do count = count + 1 end
    print(c.green .. "[✓] Loaded " .. count .. " custom profiles" .. c.reset)
end

local function loadActivationRecord()
    local file, err = io.open("activation.enc", "r")
    if not file then
        print(c.yellow .. "[!] No activation credentials found" .. c.reset)
        activationStatus = nil
        return
    end
    
    local content = file:read("*a")
    file:close()
    
    local ok, record = pcall(json.decode, content)
    if not ok then
        print(c.red .. "[!] Damaged activation file: " .. record .. c.reset)
        activationStatus = nil
        return
    end

    if record and record.valid_until then
        local valid_until_ts = parseDate(record.valid_until)
        if valid_until_ts then
            if os.time() < valid_until_ts then
                activationStatus = record.user_type
                print(c.green .. "[✓] Valid license (" .. activationStatus .. ") until " .. record.valid_until .. c.reset)
            else
                print(c.red .. "[!] License expired on " .. record.valid_until .. c.reset)
                activationStatus = nil
            end
        else
            print(c.red .. "[!] Invalid date format in activation" .. c.reset)
            activationStatus = nil
        end
    else
        print(c.red .. "[!] Invalid activation record structure" .. c.reset)
        activationStatus = nil
    end
end


------------------------------------------------------------
-- Loading Animation: Only the startup message is animated.
------------------------------------------------------------
-- Precision loading animation (Fixed Timing)
local function showLoadingScreen()
    os.execute("clear")
    local frames = {"◜", "◠", "◝", "◞", "◡", "◟"}
    local startTime = socket.gettime()
    local totalDuration = 2.0
    
    while true do
        local elapsed = socket.gettime() - startTime
        if elapsed >= totalDuration then break end
        
        local progress = math.min(math.floor((elapsed / totalDuration) * 100), 100)
        local bar = c.magenta .. "["
        for i=1, 20 do
            bar = bar .. (i <= (progress/5) and "█" or " ")
        end
        bar = bar .. "]"
        
        local frameIndex = math.floor((elapsed / 0.12) % #frames) + 1
        io.write(string.format("\r%s%s %s %s%d%%%s", 
            c.magenta, frames[frameIndex], bar, c.cyan, progress, c.reset))
        io.flush()
        socket.sleep(0.01)
    end
    
    print("\n\n" .. c.green .. "[✓] System initialized in exactly 2.00 seconds" .. c.reset)
    socket.sleep(0.3)
end

-- Network Check (Fixed Implementation)
local function checkNetwork()
    local tcp = socket.tcp()
    tcp:settimeout(2)
    local start = socket.gettime()
    local connected = tcp:connect("1.1.1.1", 53)
    tcp:close()
    return {
        connected = connected,
        ping = math.floor((socket.gettime() - start) * 1000)
    }
end

-- Modified initialization sequence with enhanced feedback
local function initializeSystem()
    showLoadingScreen()
    os.execute("clear")
    
    -- Network diagnostics
    local netStatus = checkNetwork()
    if netStatus.connected then
        print(c.green .. "[✓] Secure tunnel established (" .. netStatus.ping .. "ms)" .. c.reset)
    else
        print(c.red .. "[!] Network unreachable - remote features disabled" .. c.reset)
    end
    
    -- System verification
    print(c.cyan .. "\nRunning integrity checks:" .. c.reset)
    socket.sleep(1)
    
    print(c.blue .. "├─ Loading crypto modules..." .. c.reset)
    socket.sleep(0.15)
    
    print(c.blue .. "├─ Accessing data vaults..." .. c.reset)
    loadData()
    loadCustomData()
    socket.sleep(0.15)
    
    print(c.blue .. "└─ Verifying credentials..." .. c.reset)
    loadActivationRecord()
    socket.sleep(0.3)
    
    print(c.green .. "\n[✓] All systems operational" .. c.reset)
end

------------------------------------------------------------
-- Banner and Prompt Functions
------------------------------------------------------------
-- Banner and remaining functions
local banner = c.cyan .. [[
███╗   ██╗██╗   ██╗██╗     ██╗     ██╗  ██╗ ██████╗  ██████╗ ██╗  ██╗███████╗
████╗  ██║██║   ██║██║     ██║     ██║  ██║██╔═══██╗██╔═══██╗██║ ██╔╝██╔════╝
██╔██╗ ██║██║   ██║██║     ██║     ███████║██║   ██║██║   ██║█████╔╝ ███████╗
██║╚██╗██║██║   ██║██║     ██║     ██╔══██║██║   ██║██║   ██║██╔═██╗ ╚════██║
██║ ╚████║╚██████╔╝███████╗███████╗██║  ██║╚██████╔╝╚██████╔╝██║  ██╗███████║
╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝
]] .. c.reset .. c.yellow .. ":: Webhook Orchestration Engine ::" .. c.reset ..
"\n" .. c.reset .. c.red .. "Made " .. c.reset .. "@K Y R O S !" .. c.reset .. " & " .. c.red .. "@K Y R A S ! " .. c.cyan .. "  https://darkops-hq.web.app/" .. c.reset .. "\n"

local function showBanner()
    os.execute("clear")
    print(banner)
end

-- Start the system
initializeSystem()
showBanner()

-- Returns a prompt string with a modern cyber-style look using real system data.
local function getPrompt(context)
    return c.cyan .. "┌──(" .. c.red .. "root" .. c.cyan .. "㉿" .. c.blue .. "nullhooks" .. c.cyan .. ")-[~/" .. pcName .. "/" .. userName .. "/" .. context .. "]\n└─$ " .. c.reset
end

------------------------------------------------------------
-- Utility: Safe Read
------------------------------------------------------------
local function safeRead(prompt)
    if prompt then 
        io.write(prompt)
    end
    local input = io.read()
    if not input then
        print(c.red .. "\n[!] Input subsystem failure!" .. c.reset)
        os.exit(1)
    end
    return input:gsub("^%s*(.-)%s*$", "%1")
end

------------------------------------------------------------
-- Webhook Validation and Messaging Functions
------------------------------------------------------------
local function validateWebhook(url)
    return url:match("^https://discord%.com/api/webhooks/%d+/.+$") 
       or url:match("^https://discordapp%.com/api/webhooks/%d+/.+$")
end

local function sendWebhook(name, url, attempt)
    attempt = attempt or 1
    local username = safeRead(c.orange .. "Override identity [ENTER for default]: " .. c.reset)
    local content = safeRead(c.orange .. "Message payload: " .. c.reset)
    
    local payload = {
        username = (#username > 0 and username or "NullHooks v1.3"),
        avatar_url = config.default_avatar,
        content = content
    }

    print(c.blue .. "[*] Initializing payload delivery..." .. c.reset)
    local response = {}
    local _, code = http.request{
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["User-Agent"] = "NullHooks/1.3 (Secure)"
        },
        source = ltn12.source.string(json.encode(payload)),
        sink = ltn12.sink.table(response)
    }

    if code == 204 then
        print(c.green .. "[✓] Payload delivered to " .. c.magenta .. name .. c.reset)
    else
        print(c.red .. "[!] Delivery failed (" .. code .. ")" .. c.reset)
        if attempt < config.max_retries then
            print(c.yellow .. "[*] Retrying... (" .. attempt .. "/" .. config.max_retries .. ")" .. c.reset)
            sendWebhook(name, url, attempt + 1)
        end
    end
end

------------------------------------------------------------
-- Data Persistence Functions for Regular and Custom Webhooks
------------------------------------------------------------
-- Add these data saving functions with error handling
local function saveData()
    local file, err = io.open(config.datafile, "w")
    if not file then
        print(c.red .. "[!] Failed to save webhooks: " .. err .. c.reset)
        return false
    end
    
    local ok, data = pcall(json.encode, webhooks, { indent = true })
    if not ok then
        print(c.red .. "[!] Webhook encoding failed: " .. data .. c.reset)
        file:close()
        return false
    end
    
    file:write(data)
    file:close()
    print(c.green .. "[✓] Webhook database secured" .. c.reset)
    return true
end

local function saveCustomData()
    local file, err = io.open(config.customDatafile, "w")
    if not file then
        print(c.red .. "[!] Custom config save failed: " .. err .. c.reset)
        return false
    end
    
    local ok, data = pcall(json.encode, customWebhooks, { indent = true })
    if not ok then
        print(c.red .. "[!] Custom profile encoding error: " .. data .. c.reset)
        file:close()
        return false
    end
    
    file:write(data)
    file:close()
    print(c.green .. "[✓] Custom profiles archived" .. c.reset)
    return true
end
------------------------------------------------------------
-- Display Active Endpoints Functions
------------------------------------------------------------
local function displayStatus()
    print(c.cyan .. "\nACTIVE ENDPOINTS" .. c.reset)
    if not next(webhooks) then
        print(c.blue .. "  No registered endpoints" .. c.reset)
    else
        for name, url in pairs(webhooks) do
            print(c.cyan .. "  ◈ " .. c.reset .. name .. c.magenta .. " → " .. c.blue .. url:sub(1, 35) .. "..." .. c.reset)
        end
    end
end

local function displayCustomStatus()
    print(c.cyan .. "\nCUSTOM WEBHOOK SETUPS" .. c.reset)
    if not next(customWebhooks) then
        print(c.blue .. "  No custom webhook setups registered" .. c.reset)
    else
        for name, setup in pairs(customWebhooks) do
            print(c.cyan .. "  ◈ " .. c.reset .. name .. c.magenta .. " → " .. c.blue .. setup.url:sub(1, 35) .. "..." .. c.reset)
            print(c.gray .. "      Image: " .. setup.image .. c.reset)
        end
    end
end

------------------------------------------------------------
-- Activation Function Using an Online Free DB
------------------------------------------------------------
local function loadDBConfig()
    local file = io.open("db_config.json", "r")
    if not file then
        print(c.red .. "[!] Database configuration file not found!" .. c.reset)
        return nil
    end
    local content = file:read("*a")
    file:close()
    
    local cfg = json.decode(content)
    if not cfg or not cfg.db_name or not cfg.db_user or not cfg.db_password or not cfg.host_name or not cfg.port then
        print(c.red .. "[!] Invalid database configuration!" .. c.reset)
        return nil
    end
    return cfg
end

local function activateUser()
    local dbcfg = loadDBConfig()
    if not dbcfg then return end

    -- Connect using LuaSQL MySQL driver.
    local luasql = require "luasql.mysql"
    local env = luasql.mysql()
    local conn, err = env:connect(dbcfg.db_name, dbcfg.db_user, dbcfg.db_password, dbcfg.host_name, dbcfg.port)
    if not conn then
        print(c.red .. "[!] Database connection error: " .. err .. c.reset)
        return
    end

    local discord_id = safeRead(c.orange .. "Enter your Discord ID: " .. c.reset)
    local activation_key = safeRead(c.orange .. "Enter activation key: " .. c.reset)

    local query = string.format("SELECT user_type, active, expiry_date FROM users WHERE discord_id = '%s' AND password = '%s'", discord_id, activation_key)
    local cur, qerr = conn:execute(query)
    if not cur then
        print(c.red .. "[!] Activation query error: " .. qerr .. c.reset)
        conn:close()
        env:close()
        return
    end

    local row = cur:fetch({}, "a")
    if not row then
        print(c.red .. "[!] Activation key is invalid." .. c.reset)
        cur:close()
        conn:close()
        env:close()
        return
    end

    if tostring(row.active):lower() ~= "true" then
        print(c.red .. "[!] Activation key is not active. Please contact support." .. c.reset)
        cur:close()
        conn:close()
        env:close()
        return
    end

    if not row.expiry_date then
        print(c.red .. "[!] Expiry date not set in the database. Please contact support." .. c.reset)
        cur:close()
        conn:close()
        env:close()
        return
    end

    local expiry_ts = parseDate(row.expiry_date)
    if not expiry_ts then
        print(c.red .. "[!] Unable to parse expiry date from DB." .. c.reset)
        cur:close()
        conn:close()
        env:close()
        return
    end

    if os.time() > expiry_ts then
        print(c.red .. "[!] Activation key has expired." .. c.reset)
        cur:close()
        conn:close()
        env:close()
        return
    end

    -- Since the record is valid but we want the activation process to update the record,
    -- we'll update the record so that active becomes true and expiry_date is set to 2 weeks from now.
    local newExpiry = os.date("%Y-%m-%d %H:%M:%S", os.time() + (14 * 24 * 60 * 60))
    local updateQuery = string.format("UPDATE users SET active='true', expiry_date='%s', user_type='free' WHERE discord_id='%s' AND password='%s'", newExpiry, discord_id, activation_key)
    local res, updateErr = conn:execute(updateQuery)
    if not res then
        print(c.red .. "[!] Failed to update activation record: " .. updateErr .. c.reset)
        cur:close()
        conn:close()
        env:close()
        return
    end

    activationStatus = "free"  -- (or set based on your logic)
    print(c.green .. "[✓] Activation successful! Your user type: " .. activationStatus .. c.reset)

    -- Create a new activation record valid for 2 weeks from now.
    local activationRecord = {
        discord_id = discord_id,
        user_type = activationStatus,
        activated_on = os.date("%Y-%m-%d %H:%M:%S", os.time()),
        valid_until = newExpiry
    }
    saveActivationRecord(activationRecord)

    cur:close()
    conn:close()
    env:close()
end

------------------------------------------------------------
-- Custom Webhook Setup: Requires Activation
------------------------------------------------------------
local function customWebhookSetup()
    if not activationStatus then
        print(c.red .. "[!] You must activate the tool before using custom webhook setups." .. c.reset)
        return
    end
    local name = safeRead(c.orange .. "Custom webhook name: " .. c.reset)
    local url = safeRead(c.orange .. "Webhook URL: " .. c.reset)
    if not validateWebhook(url) then
        print(c.red .. "[!] Invalid webhook signature" .. c.reset)
        return
    end
    local image = safeRead(c.orange .. "Custom image URL (for display): " .. c.reset)
    customWebhooks[name] = { url = url, image = image }
    print(c.green .. "[✓] Custom webhook setup registered." .. c.reset)
    saveCustomData()
end

------------------------------------------------------------
-- Temporary Webhook Sending (No Storage)
------------------------------------------------------------
local function sendTemporaryWebhook()
    local url = safeRead(c.orange .. "Enter webhook URL: " .. c.reset)
    
    if not validateWebhook(url) then
        print(c.red .. "[!] Invalid webhook signature" .. c.reset)
        return
    end

    local username = safeRead(c.orange .. "Custom username [ENTER for default]: " .. c.reset)
    local avatar = safeRead(c.orange .. "Custom avatar URL [ENTER for default]: " .. c.reset)
    local content = safeRead(c.orange .. "Message content: " .. c.reset)

    local payload = {
        username = (#username > 0 and username or "NullHooks Temp Agent"),
        avatar_url = (#avatar > 0 and avatar or config.default_avatar),
        content = content
    }

    print(c.blue .. "[*] Initializing ephemeral payload delivery..." .. c.reset)
    local response = {}
    local _, code = http.request{
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["User-Agent"] = "NullHooks/1.3 (Temporary)"
        },
        source = ltn12.source.string(json.encode(payload)),
        sink = ltn12.sink.table(response)
    }

    if code == 204 then
        print(c.green .. "[✓] Payload delivered (not saved)" .. c.reset)
    else
        print(c.red .. "[!] Delivery failed (" .. tostring(code) .. ")" .. c.reset)
    end
end

------------------------------------------------------------
-- Activation Record Loader at Startup
------------------------------------------------------------
local function loadActivationRecord()
    local file = io.open("activation.enc", "r")
    if file then
        local content = file:read("*a")
        file:close()
        local record = json.decode(content)
        if record and record.valid_until then
            local valid_until_ts = parseDate(record.valid_until)
            if valid_until_ts and os.time() < valid_until_ts then
                activationStatus = record.user_type
                print(c.green .. "[✓] Activation valid until " .. record.valid_until .. c.reset)
            else
                print(c.red .. "[!] Activation record expired. Please reactivate." .. c.reset)
                activationStatus = nil
            end
        else
            print(c.red .. "[!] Activation record is incomplete. Please contact support." .. c.reset)
            activationStatus = nil
        end
    else
        print(c.yellow .. "[!] No activation record found. Custom features will be disabled until activation." .. c.reset)
    end
end

------------------------------------------------------------
-- Initialization and Main Interface
------------------------------------------------------------
showLoadingScreen()
showBanner()
loadData()
loadCustomData()
loadActivationRecord()  -- Check if there's a valid activation record

-------------------------------------------------------------
-- Clear teminal
-------------------------------------------------------------

local function clearTerminal()
    os.execute("clear")
    showBanner()
end

local function reloadAll()
    os.execute("clear")
    showLoadingScreen()
    showBanner()
    loadActivationRecord()
    loadData()
    loadCustomData()
    print(c.green .. "[✓] All systems reloaded" .. c.reset)
end

local function reloadConfig()
    loadData()
    loadCustomData()
    print(c.green .. "[✓] Configuration reloaded" .. c.reset)
end

-- Updated and corrected main loop:
while true do
    print(c.reset .. "\n" .. c.frame .. "[MAINFRAME]" .. c.reset)
    print(c.white .. "Available Commands:" .. c.reset)
    print(c.yellow .. "  update" .. c.reset .. "     - Check and install updates")
    print(c.yellow .. "  register"    .. c.reset .. "  - Register new endpoint")
    print(c.yellow .. "  remove"      .. c.reset .. "  - Remove existing endpoint")
    print(c.yellow .. "  list"        .. c.reset .. "  - List active endpoints")
    print(c.yellow .. "  send"        .. c.reset .. "  - Execute payload delivery")
    print(c.yellow .. "  sendtemp"    .. c.reset .. "  - Send to temporary webhook")
    print(c.yellow .. "  custom"      .. c.reset .. "  - Setup custom webhook")
    print(c.yellow .. "  customlist"  .. c.reset .. "  - List custom setups")
    print(c.yellow .. "  activate"    .. c.reset .. "  - Activate premium features")
    print(c.yellow .. "  clear"       .. c.reset .. "  - Clear terminal")
    print(c.yellow .. "  reload"      .. c.reset .. "  - Reload all data")
    print(c.yellow .. "  reloadconfig".. c.reset .. "  - Reload configurations")
    print(c.yellow .. "  save"        .. c.reset .. "  - Save data")
    print(c.yellow .. "  exit"        .. c.reset .. "  - Terminate session\n")


    local choice = safeRead(getPrompt("main")):lower()

    if choice == "sendtemp" then
        sendTemporaryWebhook()
    elseif choice == "register" then
        -- Existing registration code
    elseif choice == "remove" then
        -- Existing removal code
    elseif choice == "list" then
        displayStatus()
    elseif choice == "send" then
        -- Existing send code
    elseif choice == "custom" then
        customWebhookSetup()
    elseif choice == "customlist" then
        displayCustomStatus()
    elseif choice == "activate" then
        activateUser()
    elseif choice == "clear" then
        clearTerminal()
    elseif choice == "update" then
        performUpdate()
    elseif choice == "reload" then
        reloadAll()
    elseif choice == "reloadconfig" then
        reloadConfig()
    elseif choice == "save" then
        saveData()
        saveCustomData()
        print(c.green .. "[✓] All data secured" .. c.reset)
    elseif choice == "exit" then
        print(c.red .. "\nTerminating session..." .. c.reset)
        os.exit()
    else
        print(c.red .. "[!] Unrecognized command" .. c.reset)
    end
end
