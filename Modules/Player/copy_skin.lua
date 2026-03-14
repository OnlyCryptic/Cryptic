-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (عربي / إنجليزي) ]]
-- المطور: يامي | الوصف: نسخ السكن، الانيميشن (المشية)، الجسم، والاسم بالكامل

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    local originalDisplayName = lp.DisplayName 
    
    -- 🟢 حفظ سكنك الأصلي بدقة لضمان رجوعه عند الإيقاف
    local originalDesc = nil
    task.spawn(function()
        pcall(function()
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            originalDesc = hum:GetAppliedDescription()
        end)
    end)
    
    -- دالة الإشعارات المزدوجة (عربي / إنجليزي)
    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 })
        end)
    end

    -- 1. قائمة اللاعبين
    local PlayerDropdown = Tab:AddPlayerSelector("اختر اللاعب / Select Player", "ابحث عن لاعب / Search...", function(selected)
        if typeof(selected) == "Instance" and selected:IsA("Player") then
            targetPlayer = selected
        else
            targetPlayer = nil
        end
    end)
    
    local function UpdateDropdown()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then table.insert(list, p) end
        end
        if PlayerDropdown and PlayerDropdown.UpdateList then
            PlayerDropdown.UpdateList(list) 
        end
    end
    
    UpdateDropdown()
    Players.PlayerAdded:Connect(UpdateDropdown)
    Players.PlayerRemoving:Connect(UpdateDropdown)
    
    -- الجملة التوضيحية (عربي / إنجليزي)
    Tab:AddLabel("⚠️ الميزة لك فقط / Only you can see the skin")

    -- 2. زر التشغيل والإيقاف الشامل للنسخ
    Tab:AddToggle("تفعيل السكن المستنسخ / Copy Skin", function(state)
        local myChar = lp.Character
        local myHum = myChar and myChar:FindFirstChild("Humanoid")
        
        if not myHum then return end

        if state then
            -- تشغيل: نسخ شامل لكل شيء
            if not targetPlayer or not targetPlayer.Character then
                Notify("Cryptic Hub ⚠️", "يرجى اختيار لاعب موجود باللعبة!\nPlease select a valid player!")
                return
            end
            
            pcall(function()
                local targetHum = targetPlayer.Character:FindFirstChild("Humanoid")
                if targetHum then
                    -- جلب الوصف الكامل للهدف (ملابس، إكسسوارات، مشية، جسم)
                    local targetDesc = targetHum:GetAppliedDescription()
                    
                    -- تطبيق كل شيء عليك بضغطة واحدة
                    myHum:ApplyDescription(targetDesc)
                    
                    -- نسخ الاسم الوهمي اللي فوق الرأس
                    myHum.DisplayName = targetHum.DisplayName
                    
                    Notify("Cryptic Hub 🎭", "✅ تم نسخ السكن والمشية بالكامل!\nSkin & Animation fully copied!")
                end
            end)
        else
            -- إيقاف: إرجاع السكن الأصلي
            pcall(function()
                if originalDesc then
                    -- استرجاع شكلك ومشيتك الأصلية
                    myHum:ApplyDescription(originalDesc)
                else
                    -- كود احتياطي لو فشل جلب سكنك من الذاكرة
                    local fallbackDesc = Players:GetHumanoidDescriptionFromUserId(lp.UserId)
                    myHum:ApplyDescription(fallbackDesc)
                end
                
                -- استرجاع اسمك
                myHum.DisplayName = originalDisplayName
                
                Notify("Cryptic Hub 🔄", "✅ تم استرجاع سكنك الأصلي!\nOriginal skin restored!")
            end)
        end
    end)

    Tab:AddLine()
end
