-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (Local Avatar Copier) ]]
-- المطور: يامي | الوصف: نسخ السكن، الجسم، والاسم محلياً بطريقة جبرية مضمونة 100%

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    local originalDisplayName = lp.DisplayName -- لحفظ اسمك الأصلي
    
    -- دالة إرسال الإشعارات (عربي / إنجليزي)
    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 4
            })
        end)
    end

    -- 1. استدعاء قائمة اللاعبين (بدون عنوان)
    local PlayerDropdown = Tab:AddPlayerSelector("اختر اللاعب / Select Player", "ابحث عن لاعب / Search...", function(selected)
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
    
    -- 2. دالة النسخ اليدوي الجبري (تعمل 100% في كل المابات)
    local function CopyAppearance(sourceChar, targetChar)
        if not sourceChar or not targetChar then return end
        
        -- مسح ملابس وأدوات وشكل اللاعب الحالي (أنت)
        for _, v in pairs(targetChar:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("CharacterMesh") then
                v:Destroy()
            end
        end
        local targetHead = targetChar:FindFirstChild("Head")
        if targetHead then
            for _, v in pairs(targetHead:GetChildren()) do
                if v:IsA("Decal") or v:IsA("SpecialMesh") then v:Destroy() end
            end
        end

        -- استنساخ ملابس وأدوات الهدف وتركيبها عليك
        for _, v in pairs(sourceChar:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("CharacterMesh") then
                local clone = v:Clone()
                if clone then clone.Parent = targetChar end
            end
        end
        
        -- استنساخ الوجه (الفيس) وحجم الرأس
        local sourceHead = sourceChar:FindFirstChild("Head")
        if sourceHead and targetHead then
            for _, v in pairs(sourceHead:GetChildren()) do
                if v:IsA("Decal") or v:IsA("SpecialMesh") then
                    local clone = v:Clone()
                    if clone then clone.Parent = targetHead end
                end
            end
            if not targetHead:FindFirstChildOfClass("SpecialMesh") then
                local mesh = Instance.new("SpecialMesh", targetHead)
                mesh.MeshType = Enum.MeshType.Head
            end
        end

        -- نسخ الاسم الوهمي وأبعاد الجسم (الطول، العرض، النحافة)
        local sourceHum = sourceChar:FindFirstChildOfClass("Humanoid")
        local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
        if sourceHum and targetHum then
            targetHum.DisplayName = sourceHum.DisplayName
            
            local scales = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
            for _, scale in pairs(scales) do
                local sVal = sourceHum:FindFirstChild(scale)
                local tVal = targetHum:FindFirstChild(scale)
                if sVal and tVal and sVal:IsA("NumberValue") and tVal:IsA("NumberValue") then
                    tVal.Value = sVal.Value
                end
            end
        end
    end

    -- 3. زر التشغيل والإيقاف الشامل
    Tab:AddToggle("تفعيل السكن المستنسخ / Toggle Copied Skin", function(state)
        local myChar = lp.Character
        local myHum = myChar and myChar:FindFirstChild("Humanoid")
        
        if not myHum then return end

        if state then
            -- عند التشغيل: نسخ السكن
            if not targetPlayer or not targetPlayer.Character then
                Notify("Cryptic Hub ⚠️", "يرجى اختيار لاعب موجود باللعبة!\nPlease select a valid player!")
                return
            end
            
            pcall(function()
                -- استخدام الطريقة اليدوية المضمونة
                CopyAppearance(targetPlayer.Character, myChar)
                Notify("Cryptic Hub 🎭", "تم نسخ السكن والاسم بنجاح!\nSuccessfully copied skin & name!")
            end)
        else
            -- عند الإيقاف: إرجاع السكن الأصلي
            pcall(function()
                -- تحميل سكنك الأصلي من روبلوكس مباشرة
                local myDesc = Players:GetHumanoidDescriptionFromUserId(lp.UserId)
                if myDesc then
                    myHum:ApplyDescription(myDesc)
                end
                -- إرجاع اسمك
                myHum.DisplayName = originalDisplayName
                
                Notify("Cryptic Hub 🔄", "تم استرجاع سكنك الأصلي!\nOriginal skin restored successfully!")
            end)
        end
    end)

    Tab:AddLine()
end
