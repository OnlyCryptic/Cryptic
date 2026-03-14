-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين (باستخدام PlayerSelector و Toggle) ]]
-- المطور: يامي/أروى | الوصف: تحديد اللاعب ثم التشغيل لنسخ السكن والإيقاف للرجوع للأصلي

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    local targetPlayer = nil 
    
    Tab:AddParagraph("نسخ سكن / Copy Outfit", "فقط انت تقدر تشوفه / Only you can see it")
    
    -- 1. استدعاء قائمة اللاعبين (PlayerSelector)
    local PlayerDropdown = Tab:AddPlayerSelector("اختر اللاعب / Select Player", "ابحث عن لاعب...", function(selected)
        if typeof(selected) == "Instance" and selected:IsA("Player") then
            targetPlayer = selected
        else
            targetPlayer = nil
        end
    end)
    
    -- دالة لتحديث الأسماء داخل القائمة تلقائياً
    local function UpdateDropdown()
        local list = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp then table.insert(list, p) end
        end
        -- نرسل التحديث إذا كان PlayerSelector جاهزاً
        if PlayerDropdown and PlayerDropdown.UpdateList then
            PlayerDropdown.UpdateList(list) 
        end
    end
    
    UpdateDropdown()
    Players.PlayerAdded:Connect(UpdateDropdown)
    Players.PlayerRemoving:Connect(UpdateDropdown)
    
    -- 2. زر التشغيل والإيقاف (Toggle)
    Tab:AddToggle("تفعيل السكن المستنسخ / Toggle Copied Skin", function(state)
        local myChar = lp.Character
        local myHum = myChar and myChar:FindFirstChild("Humanoid")
        
        if not myHum then return end

        if state then
            -- عند التشغيل (نسخ سكن الهدف)
            if not targetPlayer then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Cryptic Hub",
                    Text = "❌ يرجى اختيار لاعب من القائمة أولاً!",
                    Duration = 3
                })
                return
            end
            
            pcall(function()
                local targetDesc = Players:GetHumanoidDescriptionFromUserId(targetPlayer.UserId)
                if targetDesc then
                    myHum:ApplyDescription(targetDesc)
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Cryptic Hub 🎭",
                        Text = "✅ تم لبس سكن [" .. targetPlayer.DisplayName .. "]",
                        Duration = 3
                    })
                end
            end)
        else
            -- عند الإيقاف (الرجوع لشكلك الأصلي)
            pcall(function()
                local myDesc = Players:GetHumanoidDescriptionFromUserId(lp.UserId)
                if myDesc then
                    myHum:ApplyDescription(myDesc)
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Cryptic Hub",
                        Text = "🔄 تم استرجاع سكنك الأصلي!",
                        Duration = 3
                    })
                end
            end)
        end
    end)

    Tab:AddLine()
end
