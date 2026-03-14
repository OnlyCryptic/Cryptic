-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (نسخ الجسم 100%) ]]
-- المطور: يامي | الوصف: تحديث تلقائي للسكن + نسخ شكل الجسم الدقيق + استرجاع مضمون

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    local isToggleOn = false
    local originalBackup = nil 

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 }) end)
    end

    -- ==========================================
    -- دوال اللحام والتنظيف
    -- ==========================================
    local function WeldAccessory(acc, targetChar)
        local handle = acc:FindFirstChild("Handle")
        if handle then
            for _, w in ipairs(handle:GetChildren()) do
                if w:IsA("Weld") or w:IsA("Motor6D") or w.Name == "AccessoryWeld" then w:Destroy() end
            end
            acc.Parent = targetChar
            local att = handle:FindFirstChildOfClass("Attachment")
            if att then
                local targetPart, targetAtt = nil, nil
                for _, part in ipairs(targetChar:GetChildren()) do
                    if part:IsA("BasePart") then
                        targetAtt = part:FindFirstChild(att.Name)
                        if targetAtt then targetPart = part; break end
                    end
                end
                if targetPart and targetAtt then
                    local weld = Instance.new("Weld")
                    weld.Name = "FakeAccessoryWeld"
                    weld.Part0 = handle
                    weld.Part1 = targetPart
                    weld.C0 = att.CFrame
                    weld.C1 = targetAtt.CFrame
                    weld.Parent = handle
                end
            end
        else
            acc.Parent = targetChar
        end
    end

    local function ClearChar(char)
        -- مسح كل شيء بما فيها شكل الجسم (CharacterMesh)
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("Highlight") or v:IsA("ForceField") or v:IsA("CharacterMesh") then
                v:Destroy()
            end
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("ParticleEmitter") or part:IsA("Fire") or part:IsA("Sparkles") or part:IsA("Trail") or part:IsA("Beam") then
                part:Destroy()
            end
        end
        local head = char:FindFirstChild("Head")
        if head then
            for _, v in ipairs(head:GetChildren()) do
                if v:IsA("Decal") or v:IsA("SpecialMesh") then v:Destroy() end
            end
        end
    end

    -- ==========================================
    -- نظام النسخ الاحتياطي لشكلك الأصلي
    -- ==========================================
    local function CreateBackup(char)
        local b = { Items = {}, Particles = {}, Scales = {}, Face = nil, HeadMesh = nil, DisplayName = lp.DisplayName, Anims = {} }
        for _, v in ipairs(char:GetChildren()) do
            -- 🟢 حفظ شكل الجسم الأصلي
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("Highlight") or v:IsA("ForceField") or v:IsA("CharacterMesh") then
                table.insert(b.Items, v:Clone())
            end
        end
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                local effects = {}
                for _, effect in ipairs(part:GetChildren()) do
                    if effect:IsA("ParticleEmitter") or effect:IsA("Fire") or effect:IsA("Sparkles") or effect:IsA("Trail") or effect:IsA("Beam") then
                        table.insert(effects, effect:Clone())
                    end
                end
                if #effects > 0 then b.Particles[part.Name] = effects end
            end
        end
        local head = char:FindFirstChild("Head")
        if head then
            for _, v in ipairs(head:GetChildren()) do
                if v:IsA("Decal") then b.Face = v:Clone()
                elseif v:IsA("SpecialMesh") then b.HeadMesh = v:Clone() end
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, scale in ipairs({"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}) do
                local val = hum:FindFirstChild(scale)
                if val and val:IsA("NumberValue") then b.Scales[scale] = val.Value end
            end
            b.DisplayName = hum.DisplayName
        end
        local anim = char:FindFirstChild("Animate")
        if anim then
            for _, obj in ipairs(anim:GetChildren()) do
                if obj:IsA("StringValue") then
                    local animData = { Value = obj.Value, Anims = {} }
                    for _, a in ipairs(obj:GetChildren()) do
                        if a:IsA("Animation") then animData.Anims[a.Name] = a.AnimationId end
                    end
                    b.Anims[obj.Name] = animData
                end
            end
        end
        return b
    end

    -- ==========================================
    -- دالة تطبيق سكن الهدف عليك
    -- ==========================================
    local function ApplyLiveSkin(sourceChar)
        local myChar = lp.Character
        local myHum = myChar and myChar:FindFirstChild("Humanoid")
        local sourceHum = sourceChar and sourceChar:FindFirstChild("Humanoid")
        if not myHum or not sourceHum then return end

        ClearChar(myChar)

        for _, v in ipairs(sourceChar:GetChildren()) do
            -- 🟢 تم إضافة CharacterMesh هنا لنسخ شكل الجسم بالضبط
            if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("Highlight") or v:IsA("ForceField") or v:IsA("CharacterMesh") then
                v:Clone().Parent = myChar
            elseif v:IsA("Accessory") then
                WeldAccessory(v:Clone(), myChar)
            end
        end

        for _, targetPart in ipairs(sourceChar:GetChildren()) do
            if targetPart:IsA("BasePart") then
                local myPart = myChar:FindFirstChild(targetPart.Name)
                if myPart then
                    for _, effect in ipairs(targetPart:GetChildren()) do
                        if effect:IsA("ParticleEmitter") or effect:IsA("Fire") or effect:IsA("Sparkles") or effect:IsA("Trail") or effect:IsA("Beam") then
                            effect:Clone().Parent = myPart
                        end
                    end
                end
            end
        end

        -- نسخ تفاصيل الرأس والوجه
        local targetHead = sourceChar:FindFirstChild("Head")
        local myHead = myChar:FindFirstChild("Head")
        if targetHead and myHead then
            for _, v in ipairs(targetHead:GetChildren()) do
                if v:IsA("Decal") or v:IsA("SpecialMesh") then v:Clone().Parent = myHead end
            end
        end

        myHum.DisplayName = sourceHum.DisplayName
        for _, scale in ipairs({"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}) do
            local sVal = sourceHum:FindFirstChild(scale)
            local tVal = myHum:FindFirstChild(scale)
            if sVal and tVal and sVal:IsA("NumberValue") and tVal:IsA("NumberValue") then tVal.Value = sVal.Value end
        end

        local targetAnimate = sourceChar:FindFirstChild("Animate")
        local myAnimate = myChar:FindFirstChild("Animate")
        if targetAnimate and myAnimate then
            for _, obj in ipairs(targetAnimate:GetChildren()) do
                local myObj = myAnimate:FindFirstChild(obj.Name)
                if myObj and obj:IsA("StringValue") and myObj:IsA("StringValue") then
                    myObj.Value = obj.Value
                    for _, anim in ipairs(obj:GetChildren()) do
                        if anim:IsA("Animation") then
                            local myAnim = myObj:FindFirstChild(anim.Name)
                            if myAnim and myAnim:IsA("Animation") then myAnim.AnimationId = anim.AnimationId end
                        end
                    end
                end
            end
        end
    end

    local function RestoreOriginalSkin()
        if not originalBackup then return end
        local myChar = lp.Character
        local myHum = myChar and myChar:FindFirstChild("Humanoid")
        if not myHum then return end

        ClearChar(myChar)

        for _, item in ipairs(originalBackup.Items) do
            local clone = item:Clone()
            if clone:IsA("Accessory") then WeldAccessory(clone, myChar) else clone.Parent = myChar end
        end

        for partName, effects in pairs(originalBackup.Particles) do
            local myPart = myChar:FindFirstChild(partName)
            if myPart then
                for _, effect in ipairs(effects) do effect:Clone().Parent = myPart end
            end
        end

        local myHead = myChar:FindFirstChild("Head")
        if myHead then 
            if originalBackup.Face then originalBackup.Face:Clone().Parent = myHead end
            if originalBackup.HeadMesh then originalBackup.HeadMesh:Clone().Parent = myHead end
        end

        myHum.DisplayName = originalBackup.DisplayName
        for scale, val in pairs(originalBackup.Scales) do
            local tVal = myHum:FindFirstChild(scale)
            if tVal and tVal:IsA("NumberValue") then tVal.Value = val end
        end

        local myAnimate = myChar:FindFirstChild("Animate")
        if myAnimate then
            for objName, data in pairs(originalBackup.Anims) do
                local myObj = myAnimate:FindFirstChild(objName)
                if myObj and myObj:IsA("StringValue") then
                    myObj.Value = data.Value
                    for animName, animId in pairs(data.Anims) do
                        local myAnim = myObj:FindFirstChild(animName)
                        if myAnim and myAnim:IsA("Animation") then myAnim.AnimationId = animId end
                    end
                end
            end
        end
    end

    -- ==========================================
    -- بناء الواجهة
    -- ==========================================
    Tab:AddLabel("⚠️ الميزة لك فقط / Only you can see the skin")

    local PlayerDropdown = Tab:AddPlayerSelector("اختر اللاعب / Select Player", "ابحث عن لاعب / Search...", function(selected)
        targetPlayer = (typeof(selected) == "Instance" and selected:IsA("Player")) and selected or nil
        
        if isToggleOn and targetPlayer and targetPlayer.Character then
            pcall(function()
                ApplyLiveSkin(targetPlayer.Character)
                Notify("Cryptic Hub 🎭", "تم تحديث السكن إلى: " .. targetPlayer.DisplayName)
            end)
        end
    end)
    
    local function UpdateDropdown()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then table.insert(list, p) end
        end
        if PlayerDropdown and PlayerDropdown.UpdateList then PlayerDropdown.UpdateList(list) end
    end
    
    UpdateDropdown()
    Players.PlayerAdded:Connect(UpdateDropdown)
    Players.PlayerRemoving:Connect(UpdateDropdown)

    Tab:AddToggle("تفعيل السكن المستنسخ / Copy Skin", function(state)
        isToggleOn = state
        local myChar = lp.Character
        if not myChar then return end

        if state then
            if not targetPlayer or not targetPlayer.Character then
                Notify("Cryptic Hub ⚠️", "يرجى اختيار لاعب موجود باللعبة!\nPlease select a valid player!")
                return
            end
            
            pcall(function()
                if not originalBackup then originalBackup = CreateBackup(myChar) end
                ApplyLiveSkin(targetPlayer.Character)
                Notify("Cryptic Hub 🎭", "✅ تم النسخ بالكامل!\nEverything fully copied!")
            end)
        else
            pcall(function()
                RestoreOriginalSkin()
                Notify("Cryptic Hub 🔄", "✅ تم استرجاع سكنك الأصلي!\nOriginal skin restored!")
            end)
        end
    end)

    lp.CharacterAdded:Connect(function(newChar)
        originalBackup = nil 
        task.delay(1, function()
            if isToggleOn and targetPlayer and targetPlayer.Character then
                originalBackup = CreateBackup(newChar)
                ApplyLiveSkin(targetPlayer.Character)
            end
        end)
    end)

    Tab:AddLine()
end
