-- installer.lua

local files = {
    {
        url = "https://raw.githubusercontent.com/spamthisemail1999-ship-it/ATM-10-CC-Tweaked-Test/refs/heads/main/startup.lua?token=GHSAT0AAAAAAEDCS4UT2PAON2CWYZAGPURG2S2W6RA",
        name = "startup.lua"
    },
    {
        url = "https://raw.githubusercontent.com/spamthisemail1999-ship-it/ATM-10-CC-Tweaked-Test/refs/heads/main/config.lua?token=GHSAT0AAAAAAEDCS4UTQXJ2UCE53NPL3Q6K2S2W6TQ",
        name = "config.lua"
    },
    {
        url = "https://raw.githubusercontent.com/spamthisemail1999-ship-it/ATM-10-CC-Tweaked-Test/refs/heads/main/colony_manager.lua?token=GHSAT0AAAAAAEDCS4USUZP3RG735ZWNSAEE2S2W6VA",
        name = "colony_manager.lua"
    }
}

for _, file in ipairs(files) do
    print("Downloading " .. file.name .. "...")

    if fs.exists(file.name) then
        fs.delete(file.name)
    end

    local ok = shell.run("wget", file.url, file.name)

    if ok then
        print("✓ Installed " .. file.name)
    else
        print("✗ Failed to download " .. file.name)
    end
end

print("Download Complete!")
