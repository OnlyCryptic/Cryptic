-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (الإصدار الذهبي والخالي من الأخطاء 100%) ]]
-- المطور: يامي | الوصف: تحكم حر وطبيعي + نسخ الهيكل العظمي لمنع التشوه + استرجاع دقيق

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    local isToggleOn = false
    local originalState = nil 

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 }) end)
    end

    -- ==========================================
    -- نظام حفظ واسترجاع حالتك الأصلية
    -- ==========================================
    local function SaveOriginalState(char)
        if originalState then return end
        originalState = { Props = {}, Motors = {}, Scales = {}, DisplayName = lp.DisplayName }

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then 
            originalState.DisplayName = hum.DisplayName 
            local scales = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
            for _, scale in ipairs(scales) do
                local val = hum:FindFirstChild(scale)
                if val and val:IsA("NumberValue") then originalState.Scales[scale] = val.Value end
            end
        end

        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                originalState.Props[v] = { Transparency = v.Transparency }
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Highlight") or v:IsA("ForceField") then
                originalState.Props[v] = { Enabled = v.Enabled }
            elseif v:IsA("Motor6D") then
                originalState.Motors[v] = { C0 = v.C0, C1 = v.C1 }
            end
        end
    end

    local function RestoreOriginalState()
        local myChar = lp.Character
        if not myChar or not originalState then return end

        local morph = myChar:FindFirstChild("FakeMorph")
        if morph then morph:Destroy() end

        for obj, props in pairs(originalState.Props) do
            if obj and obj.Parent then
                if props.Transparency ~= nil then obj.Transparency = props.Transparency end
                if props.Enabled ~= nil then obj.Enabled = props.Enabled end
            end
        end

        for motor, cframes in pairs(originalState.Motors) do
            if motor and motor.Parent then
                motor.C0 = cframes.C0
                motor.C1 = cframes.C1
            end
        end

        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.DisplayName = originalState.DisplayName 
            for scale, val in pairs(originalState.Scales) do
                local tVal = hum:FindFirstChild(scale)
                if tVal and tVal:IsA("NumberValue") then tVal.Value = val end
            end
        end
    end

    -- ==========================================
    -- دالة النسخ الفعلي (نظام الدرع العظمي)
    -- ==========================================
    local function ApplyPerfectMorph(sourceChar)
        local myChar = lp.Character
        if not myChar or not sourceChar then return end

        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        local sourceHum = sourceChar:FindFirstChildOfClass("Humanoid")
        if not myHum or not sourceHum then return end

        if myHum.RigType ~= sourceHum.RigType then
            Notify("Cryptic Hub ⚠️", "لا يمكن النسخ: نوع الجسم مختلف (R6 / R15)!\nRig types must match!")
            return
        end

        RestoreOriginalState()
        SaveOriginalState(myChar)

        -- 1. تعديل حجم مفاصل جسمك الخفي ليتطابق بالمليمتر مع الهدف (هذا يمنع التفكك والمربعات)
        for _, myMotor in ipairs(myChar:GetDescendants()) do
            if myMotor:IsA("Motor6D") then
                local targetPart = sourceChar:FindFirstChild(myMotor.Parent.Name)
                if targetPart then
                    local targetMotor = targetPart:FindFirstChild(myMotor.Name)
                    if targetMotor and targetMotor:IsA("Motor6D") then
                        myMotor.C0 = targetMotor.C0
                        myMotor.C1 = targetMotor.C1
                    end
                end
            end
        end

        local scales = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
        for _, scale in ipairs(scales) do
            local sVal = sourceHum:FindFirstChild(scale)
            local tVal = myHum:FindFirstChild(scale)
            if sVal and tVal and sVal:IsA("NumberValue") and tVal:IsA("NumberValue") then tVal.Value = sVal.Value end
        end

        task.wait(0.05) -- انتظار تطبيق شكل الجسم

        -- 2. إخفاء جسمك الأصلي بالكامل
        for _, v in ipairs(myChar:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Transparency = 1
            elseif v:IsA("Decal") and v.Name == "face" then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Highlight") or v:IsA("ForceField") then
                v.Enabled = false
            end
        end

        -- 3. استنساخ الهدف وتجهيز بدلة الدمية
        sourceChar.Archivable = true
        local morph = sourceChar:Clone()
        morph.Name = "FakeMorph"

        local morphHum = morph:FindFirstChildOfClass("Humanoid")
        if morphHum then
            morphHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            morphHum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
            morphHum.PlatformStand = true
            local animator = morphHum:FindFirstChildOfClass("Animator")
            if animator then animator:Destroy() end
        end

        -- 4. اللحام الخفيف السريع (بدون إيقاف حركتك)
        for _, v in ipairs(morph:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") then
                v:Destroy()
            elseif v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("WeldConstraint") then
                -- لا نحذف لحامات الإكسسوارات لكي لا تسقط القبعات
                if not v:FindFirstAncestorOfClass("Accessory") then
                    v:Destroy()
                end
            elseif v:IsA("BasePart") then
                v.CanCollide = false
                v.Massless = true
                v.Anchored = false
                if v.Name == "HumanoidRootPart" then v.Transparency = 1 end
                
                -- ربط أجزاء البدلة بأجزاء جسمك
                local myPart = myChar:FindFirstChild(v.Name)
                if myPart then
                    local weld = Instance.new("Weld")
                    weld.Name = "ArmorWeld"
                    weld.Part0 = myPart
                    weld.Part1 = v
                    weld.C0 = CFrame.new()
                    weld.C1 = CFrame.new()
                    weld.Parent = v
                end
            end
        end

        myHum.DisplayName = sourceHum.DisplayName
        morph.Parent = myChar
    end

    -- ==========================================
    -- بناء الواجهة
    -- ==========================================
    Tab:AddLabel("⚠️ الميزة لك فقط / Only you can see the skin")

    local PlayerDropdown = Tab:AddPlayerSelector("اختر اللاعب / Select Player", "ابحث عن لاعب / Search...", function(selected)
        targetPlayer = (typeof(selected) == "Instance" and selected:IsA("Player")) and selected or nil
        
        if isToggleOn and targetPlayer and targetPlayer.Character then
            pcall(function()
                ApplyPerfectMorph(targetPlayer.Character)
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
                ApplyPerfectMorph(targetPlayer.Character)
                Notify("Cryptic Hub 🎭", "✅ تم النسخ! تحكمك حر بالكامل!\nPerfect copy with normal controls!")
            end)
        else
            pcall(function()
                RestoreOriginalState()
                Notify("Cryptic Hub 🔄", "✅ تم استرجاع سكنك الأصلي!\nOriginal skin restored!")
            end)
        end
    end)

    lp.CharacterAdded:Connect(function()
        originalState = nil 
        task.delay(1, function()
            if isToggleOn and targetPlayer and targetPlayer.Character then
                ApplyPerfectMorph(targetPlayer.Character)
            end
        end)
    end)

    Tab:AddLine()
end
