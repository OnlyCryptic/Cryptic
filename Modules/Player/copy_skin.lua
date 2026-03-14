-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (100% Fix) ]]
-- المطور: يامي | الوصف: نسخ جبري (شعر، ملابس، وجه، ألوان، جسم) مع استرجاع سليم

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    local originalDisplayName = lp.DisplayName 

    -- دالة الإشعارات (عربي / إنجليزي)
    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 })
        end)
    end

    -- 1. قائمة اختيار اللاعبين
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
    
    -- الجملة التوضيحية
    Tab:AddLabel("⚠️ الميزة لك فقط / Only you can see the skin")

    -- 2. زر التشغيل والإيقاف الشامل للنسخ
    Tab:AddToggle("تفعيل السكن المستنسخ / Copy Skin", function(state)
        local myChar = lp.Character
        local myHum = myChar and myChar:FindFirstChild("Humanoid")
        if not myHum then return end

        if state then
            -- 🟢 تفعيل النسخ (تشغيل)
            if not targetPlayer or not targetPlayer.Character then
                Notify("Cryptic Hub ⚠️", "يرجى اختيار لاعب موجود باللعبة!\nPlease select a valid player!")
                return
            end
            
            local targetChar = targetPlayer.Character
            local targetHum = targetChar:FindFirstChild("Humanoid")
            
            pcall(function()
                -- 1. تنظيف سكنك الحالي بالكامل
                for _, v in ipairs(myChar:GetChildren()) do
                    if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("CharacterMesh") then
                        v:Destroy()
                    end
                end
                local myHead = myChar:FindFirstChild("Head")
                if myHead then
                    for _, v in ipairs(myHead:GetChildren()) do
                        if v:IsA("Decal") or v:IsA("SpecialMesh") then v:Destroy() end
                    end
                end

                -- 2. نسخ ولصق أغراض الهدف مع إصلاح اللحام (Welds)
                for _, v in ipairs(targetChar:GetChildren()) do
                    if v:IsA("Accessory") then
                        local clone = v:Clone()
                        -- 🟢 السر هنا: حذف اللحام القديم عشان يركب عليك صح وما يختفي
                        local handle = clone:FindFirstChild("Handle")
                        if handle then
                            for _, weld in ipairs(handle:GetChildren()) do
                                if weld:IsA("Weld") or weld:IsA("Motor6D") or weld.Name == "AccessoryWeld" then
                                    weld:Destroy()
                                end
                            end
                        end
                        myHum:AddAccessory(clone)
                    elseif v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("CharacterMesh") then
                        v:Clone().Parent = myChar
                    end
                end

                -- 3. نسخ الوجه
                local targetHead = targetChar:FindFirstChild("Head")
                if targetHead and myHead then
                    for _, v in ipairs(targetHead:GetChildren()) do
                        if v:IsA("Decal") or v:IsA("SpecialMesh") then
                            v:Clone().Parent = myHead
                        end
                    end
                end

                -- 4. نسخ الاسم وحجم/عرض الجسم
                if targetHum then
                    myHum.DisplayName = targetHum.DisplayName
                    local scales = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
                    for _, scale in ipairs(scales) do
                        local sVal = targetHum:FindFirstChild(scale)
                        local tVal = myHum:FindFirstChild(scale)
                        if sVal and tVal and sVal:IsA("NumberValue") and tVal:IsA("NumberValue") then
                            tVal.Value = sVal.Value
                        end
                    end
                end

                Notify("Cryptic Hub 🎭", "✅ تم النسخ بالكامل!\nEverything fully copied!")
            end)
        else
            -- 🟢 إيقاف الميزة (الرجوع للسكن الأصلي)
            pcall(function()
                -- جلب سكنك الأصلي من حسابك في روبلوكس مباشرة (أضمن طريقة 100%)
                local myDesc = Players:GetHumanoidDescriptionFromUserId(lp.UserId)
                if myDesc then
                    myHum:ApplyDescription(myDesc)
                end
                -- إرجاع اسمك
                myHum.DisplayName = originalDisplayName
                
                Notify("Cryptic Hub 🔄", "✅ تم استرجاع سكنك الأصلي!\nOriginal skin restored!")
            end)
        end
    end)

    Tab:AddLine()
end
