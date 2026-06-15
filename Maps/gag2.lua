-- [[ Cryptic Hub - Map: Wizard Alchemy ]]
-- جميع إيديات Wizard Alchemy تشير لهذا الملف

return {
    Name = "grow a garden 2",
    Scripts = {
        {
            Name = "Teddy hub no key",
            Script = [[repeat task.wait() until game:IsLoaded() and game:GetService("Players") and game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui")

loadstring(game:HttpGet("https://raw.githubusercontent.com/Teddyseetink/Haidepzai/refs/heads/main/main.lua"))()
]]
        }
    }
}