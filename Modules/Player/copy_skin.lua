-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل والمضمون ]]
-- المطور: يامي | الوصف: نسخ دقيق 100% مع استرجاع مضمون للسكن الأصلي

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    local originalDisplayName = lp.DisplayName 
    
    -- 🟢 حفظ سكنك الأصلي في الذاكرة بمجرد تشغيل السكربت لضمان رجوعه
    local originalDesc = nil
    task.spawn(function()
        pcall(function()
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            originalDesc = hum:GetAppliedDescription()
        end)
        -- إذا فشل، يحمله من حسابك في روبلوكس مباشرة
        if not originalDesc then
            pcall(function()
                originalDesc = Players:GetHumanoidDescriptionFromUserId(lp.UserId)
            end)
        end
    end)
    
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
    
    -- 2. دالة النسخ اليدوي (تم إصلاحها لنسخ وتركيب الإكسسوارات بشكل صحيح)
    local function CopyAppearance(sourceChar, targetChar)
        local sourceHum = sourceChar:FindFirstChildOfClass("Humanoid")
        local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
        if not sourceHum or not targetHum then return end

        -- تنظيف شخصيتك الحالية
        for _, v in ipairs(targetChar:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("CharacterMesh") then
                v:Destroy()
            end
        end
        local targetHead = targetChar:FindFirstChild("Head")
        if targetHead then
            for _, v in ipairs(targetHead:GetChildren()) do
                if v:IsA("Decal") or v:IsA("SpecialMesh") then v:Destroy() end
            end
        end

        -- استنساخ أغراض الهدف وتركيبها
        for _, v in ipairs(sourceChar:GetChildren()) do
            if v:IsA("Accessory") then
                -- 🟢 الإكسسوارات (الشعر والقبعات) تحتاج دالة خاصة لتركيبها
                local clone = v:Clone()
                targetHum:AddAccessory(clone) 
            elseif v:IsA("Clothing") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("CharacterMesh") then
                local clone = v:Clone()
                clone.Parent = targetChar
            end
        end
        
        -- نسخ الوجه
        local sourceHead = sourceChar:FindFirstChild("Head")
        if sourceHead and targetHead then
            for _, v in ipairs(sourceHead:GetChildren()) do
                if v:IsA("Decal") or v:IsA("SpecialMesh") then
                    v:Clone().Parent = targetHead
                end
            end
            if not targetHead:FindFirstChildOfClass("SpecialMesh") then
                local mesh = Instance.new("SpecialMesh", targetHead)
                mesh.MeshType = Enum.MeshType.Head
            end
        end

        -- نسخ الاسم الوهمي وتفاصيل حجم الجسم
        targetHum.DisplayName = sourceHum.DisplayName
        local scales = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
        for _, scale in ipairs(scales) do
            local sVal = sourceHum:FindFirstChild(scale)
            local tVal = targetHum:FindFirstChild(scale)
            if sVal and tVal and sVal:IsA("NumberValue") and tVal:IsA("NumberValue") then
                tVal.Value = sVal.Value
            end
        end
    end

    -- 🟢 الجملة التوضيحية التي طلبتها
    Tab:AddLabel("⚠️ الميزة لك فقط (فقط انت تقدر تشوف السكن)")

    -- 3. زر التشغيل والإيقاف الشامل
    Tab:AddToggle("تفعيل السكن المستنسخ / Copy Skin", function(state)
        local myChar = lp.Character
        local myHum = myChar and myChar:FindFirstChild("Humanoid")
        
        if not myHum then return end

        if state then
            -- تشغيل: نسخ
            if not targetPlayer or not targetPlayer.Character then
                Notify("Cryptic Hub ⚠️", "يرجى اختيار لاعب موجود باللعبة!\nPlease select a valid player!")
                return
            end
            
            pcall(function()
                CopyAppearance(targetPlayer.Character, myChar)
                Notify("Cryptic Hub 🎭", "تم نسخ السكن بالكامل بنجاح!\nSkin fully copied!")
            end)
        else
            -- إيقاف: إرجاع السكن الأصلي من الذاكرة
            pcall(function()
                if originalDesc then
                    myHum:ApplyDescription(originalDesc)
                else
                    local fallbackDesc = Players:GetHumanoidDescriptionFromUserId(lp.UserId)
                    myHum:ApplyDescription(fallbackDesc)
                end
                myHum.DisplayName = originalDisplayName
                
                Notify("Cryptic Hub 🔄", "تم استرجاع سكنك الأصلي!\nOriginal skin restored!")
            end)
        end
    end)

    Tab:AddLine()
end
