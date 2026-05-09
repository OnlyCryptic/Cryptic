-- [[ Cryptic Hub - قسم السيرفر ]]
-- المطور: يامي (Yami) | التحديث: عرض معلومات السيرفر فقط (بدون أدوات انتقال)

return function(Tab, UI)
    local Players = game:GetService("Players")
    local Market = game:GetService("MarketplaceService")

    -- 1. حالة السيرفر (تحديث مباشر لاسم الماب وعدد اللاعبين)
    local StatusLabel = Tab:AddLabel("📊 جاري جلب المعلومات...")

    task.spawn(function()
        local gameName = game.Name
        pcall(function()
            gameName = Market:GetProductInfo(game.PlaceId).Name
        end)
        
        local function updateStatus()
            -- دمج اسم الماب وعدد اللاعبين في سطر واحد
            StatusLabel.SetText("🎮 " .. gameName .. " | 👥 " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
        end
        
        updateStatus()
        Players.PlayerAdded:Connect(updateStatus)
        Players.PlayerRemoving:Connect(updateStatus)
    end)
end
