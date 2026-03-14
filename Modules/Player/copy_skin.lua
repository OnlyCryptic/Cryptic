-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (Local Avatar Copier) ]]
-- المطور: يامي/أروى | الوصف: نسخ السكن، الجسم، المشية، والاسم محلياً

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    local targetPlayer = nil 
    local originalDisplayName = lp.DisplayName -- لحفظ اسمك الأصلي
    
    -- 1. استدعاء قائمة اللاعبين (بدون العنوان كما طلبت)
    local PlayerDropdown = Tab:AddPlayerSelector("اختر اللاعب / Select Player", "ابحث عن لاعب...", function(selected)
        if typeof(selected) == "Instance" and selected:IsA("Player") then
            targetPlayer = selected
        else
            targetPlayer = nil
        end
    end)
    
    local function UpdateDropdown()
        local list = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp then table.insert(list, p) end
        end
        if PlayerDropdown and PlayerDropdown.UpdateList then
            PlayerDropdown.UpdateList(list) 
        end
    end
    
    UpdateDropdown()
    Players.PlayerAdded:Connect(UpdateDropdown)
    Players.PlayerRemoving:Connect(UpdateDropdown)
    
    -- 2. زر التشغيل والإيقاف الشامل
    Tab:AddToggle("تفعيل السكن المستنسخ / Toggle Copied Skin", function(state)
        local myChar = lp.Character
        local myHum = myChar and myChar:FindFirstChild("Humanoid")
        
        if not myHum then return end

        if state then
            -- التأكد أن اللاعب محدد وموجود في الماب
            if not targetPlayer or not targetPlayer.Character then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Cryptic Hub",
                    Text = "❌ يرجى اختيار لاعب موجود داخل الماب!",
                    Duration = 3
                })
                return
            end
            
            local targetChar = targetPlayer.Character
            local targetHum = targetChar:FindFirstChild("Humanoid")
            
            if targetHum then
                pcall(function()
                    -- جلب كل تفاصيل اللاعب الحالية (ملابس، جسم، مشية) وتطبيقها عليك
                    local targetDesc = targetHum:GetAppliedDescription()
                    myHum:ApplyDescription(targetDesc)
                    
                    -- نسخ الاسم الذي يظهر فوق الرأس
                    myHum.DisplayName = targetHum.DisplayName
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Cryptic Hub 🎭",
                        Text = "✅ تم نسخ سكن، مشية، واسم [" .. targetPlayer.DisplayName .. "]",
                        Duration = 4
                    })
                end)
            end
        else
            -- الرجوع لحالتك الأصلية
            pcall(function()
                -- استرجاع سكنك الأصلي من سيرفرات روبلوكس
                local myDesc = Players:GetHumanoidDescriptionFromUserId(lp.UserId)
                myHum:ApplyDescription(myDesc)
                
                -- استرجاع اسمك الأصلي فوق الرأس
                myHum.DisplayName = originalDisplayName
                
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Cryptic Hub",
                    Text = "🔄 تم استرجاع سكنك واسمك الأصلي!",
                    Duration = 3
                })
            end)
        end
    end)

    Tab:AddLine()
end
