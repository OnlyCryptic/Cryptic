-- [[ Cryptic Hub - Map: Grow a Garden 2 ]]
-- جميع إيديات Grow a Garden 2 تشير لهذا الملف

return {
    Name = "grow a garden 2",
    Scripts = {
        {
            Name = "Teddy hub no key",
            Script = [[repeat task.wait() until game:IsLoaded() and game:GetService("Players") and game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui")

loadstring(game:HttpGet("https://raw.githubusercontent.com/Teddyseetink/Haidepzai/refs/heads/main/main.lua"))()
]]
        },
        {
            Name = "Real Kid Hub",
            Script = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/main.lua"))()]]
        },
        {
            Name = "Speed Hub (need key 🔒😔)",
            Script = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()]]
        }
    }
}