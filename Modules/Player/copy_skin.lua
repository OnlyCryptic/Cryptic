-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (Local Avatar Copier) ]]
-- المطور: يامي | الوصف: نسخ جبري شامل (اكسسوارات، جسم، مشية، اسم) بدون أخطاء

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    
    -- متغيرات لحفظ سكنك الأصلي لضمان رجوعه
    local originalSaved = false
    local originalItems = {}
    local originalScales = {}
    local originalName = lp.DisplayName

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

    -- دالة مسح السكن الحالي لتجهيز تركيب السكن الجديد
    local function ClearCharacter(char)
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("CharacterMesh") then
                v:Destroy()
            end
        end
        local head = char:FindFirstChild("Head")
        if head then
            for _, v in ipairs(head:GetChildren()) do
                if v:IsA("Decal") or v:IsA("SpecialMesh") then v:Destroy() end
            end
        end
    end

    -- دالة حفظ سكنك الأصلي في الذاكرة
    local function SaveOriginal(char)
        if originalSaved then return end
        originalSaved = true
        originalName = lp.DisplayName
        
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("CharacterMesh") then
                table.insert(originalItems, v:Clone())
            end
        end
        local head = char:FindFirstChild("Head")
        if head then
            for _, v in ipairs(head:GetChildren()) do
                if v:IsA("Decal") or v:IsA("SpecialMesh") then table.insert(originalItems, v:Clone()) end
            end
        end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local scales = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
            for _, scale in ipairs(scales) do
                local val = hum:FindFirstChild(scale)
                if val and val:IsA("NumberValue") then originalScales[scale] = val.Value end
            end
        end
    end

    -- دالة تركيب الأغراض والانيميشن على اللاعب
    local function ApplyItems(char, items, sourceHum, sourceAnim)
        local hum = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head")
        
        for _, item in ipairs(items) do
            local clone = item:Clone()
            if clone:IsA("Accessory") then
                if hum then hum:AddAccessory(clone) else clone.Parent = char end
            elseif clone:IsA("Decal") or clone:IsA("SpecialMesh") then
                if head then clone.Parent = head end
            else
                clone.Parent = char
            end
        end
        
        if sourceHum and hum then
            local scales = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
            for _, scale in ipairs(scales) do
                local sVal = sourceHum:FindFirstChild(scale)
                local tVal = hum:FindFirstChild(scale)
                if sVal and tVal and sVal:IsA("NumberValue") and tVal:IsA("NumberValue") then
                    tVal.Value = sVal.Value
                end
            end
            hum.DisplayName = sourceHum.DisplayName
        end

        -- نسخ انيميشن المشية (Walk Animation)
        local myAnim = char:FindFirstChild("Animate")
        if sourceAnim and myAnim then
            for _, animFolder in ipairs(sourceAnim:GetChildren()) do
                local myFolder = myAnim:FindFirstChild(animFolder.Name)
                if myFolder then
                    for _, anim in ipairs(animFolder:GetChildren()) do
                        if anim:IsA("Animation") then
                            local myTargetAnim = myFolder:FindFirstChild(anim.Name)
                            if myTargetAnim and myTargetAnim:IsA("Animation") then
                                myTargetAnim.AnimationId = anim.AnimationId
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. زر التشغيل والإيقاف الشامل للنسخ
    Tab:AddToggle("تفعيل السكن المستنسخ / Copy Skin", function(state)
        local myChar = lp.Character
        local myHum = myChar and myChar:FindFirstChild("Humanoid")
        if not myHum then return end

        if state then
            if not targetPlayer or not targetPlayer.Character then
                Notify("Cryptic Hub ⚠️", "يرجى اختيار لاعب موجود باللعبة!\nPlease select a valid player!")
                return
            end
            
            pcall(function()
                SaveOriginal(myChar) -- حفظ شكلك الأصلي
                
                local targetChar = targetPlayer.Character
                local targetItems = {}
                
                -- تجميع أغراض الهدف
                for _, v in ipairs(targetChar:GetChildren()) do
                    if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("CharacterMesh") then
                        table.insert(targetItems, v)
                    end
                end
                local tHead = targetChar:FindFirstChild("Head")
                if tHead then
                    for _, v in ipairs(tHead:GetChildren()) do
                        if v:IsA("Decal") or v:IsA("SpecialMesh") then table.insert(targetItems, v) end
                    end
                end
                
                ClearCharacter(myChar) -- مسح شكلك
                -- تركيب شكل الهدف واسمه ومشيته
                ApplyItems(myChar, targetItems, targetChar:FindFirstChildOfClass("Humanoid"), targetChar:FindFirstChild("Animate"))
                
                Notify("Cryptic Hub 🎭", "✅ تم النسخ بالكامل (إكسسوارات، مشية، جسم)!\nEverything fully copied!")
            end)
        else
            -- إرجاع شكلك الأصلي
            pcall(function()
                if originalSaved then
                    ClearCharacter(myChar)
                    ApplyItems(myChar, originalItems, nil, nil)
                    
                    for scale, val in pairs(originalScales) do
                        local tVal = myHum:FindFirstChild(scale)
                        if tVal and tVal:IsA("NumberValue") then tVal.Value = val end
                    end
                    myHum.DisplayName = originalName
                    
                    Notify("Cryptic Hub 🔄", "✅ تم استرجاع سكنك الأصلي!\nOriginal skin restored!")
                end
            end)
        end
    end)

    Tab:AddLine()
end
