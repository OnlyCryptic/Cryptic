-- [[ Cryptic Hub - Server Info ]]

local i18n = getgenv().CrypticI18n
local T = (i18n and i18n.T) or function(k) return k end

return function(Tab, UI)
    local Players = game:GetService("Players")
    local Market = game:GetService("MarketplaceService")

    local StatusLabel = Tab:AddLabel("📊 " .. T("server.info.loading"))

    task.spawn(function()
        local gameName = game.Name
        pcall(function()
            gameName = Market:GetProductInfo(game.PlaceId).Name
        end)

        local function updateStatus()
            StatusLabel.SetText("🎮 " .. gameName .. " | 👥 " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
        end

        updateStatus()
        Players.PlayerAdded:Connect(updateStatus)
        Players.PlayerRemoving:Connect(updateStatus)
    end)
end
