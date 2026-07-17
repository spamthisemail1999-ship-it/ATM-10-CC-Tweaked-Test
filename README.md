-- installer.lua

local files = {
    {
        url = "https://raw.githubusercontent.com/spamthisemail1999-ship-it/ATM-10-CC-Tweaked-Test/refs/heads/main/startup.lua",
        name = "startup.lua"
    },
    {
        url = "https://raw.githubusercontent.com/spamthisemail1999-ship-it/ATM-10-CC-Tweaked-Test/refs/heads/main/config.lua",
        name = "config.lua"
    },
    {
        url = "https://raw.githubusercontent.com/spamthisemail1999-ship-it/ATM-10-CC-Tweaked-Test/refs/heads/main/colony_manager.lua",
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
