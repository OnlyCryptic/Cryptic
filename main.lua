local success, err = pcall(function()
    
    loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyCryptic/Cryptic/test/main.lua?v="..tick()))()
end)

if not success then
    warn("❌ Cryptic Hub Loader Error: " .. tostring(err))
end
