-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (الإصدار الذهبي والخالي من الأخطاء) ]]
-- المطور: يامي | الوصف: ملابس كاملة + حجم دقيق + تحكم طبيعي وبدون لاق

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    local isToggleOn = false
    local originalState = nil 
    local syncConnection = nil 
    local fakeClone = nil

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 }) end)
    end

    -- ==========================================
    -- نظام حفظ واسترجاع حالتك الأصلية
    -- ==========================================
    local function SaveOriginalState(char)
        if originalState then return end
        originalState = { Props = {}, Scales = {}, DisplayName = lp.DisplayName }

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
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                originalState.Props[v] = { Transparency = v.Transparency }
            elseif v:IsA("Decal") and v.Name == "face" then
                originalState.Props[v] = { Transparency = v.Transparency }
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Highlight") or v:IsA("ForceField") then
                originalState.Props[v] = { Enabled = v.Enabled }
            end
        end
    end

    local function RestoreOriginalState()
        local myChar = lp.Character
        if not myChar or not originalState then return end

        if syncConnection then syncConnection:Disconnect(); syncConnection = nil end
        if fakeClone then fakeClone:Destroy(); fakeClone = nil end

        for obj, props in pairs(originalState.Props) do
            if obj and obj.Parent then
                if props.Transparency ~= nil then obj.Transparency = props.Transparency end
                if props.Enabled ~= nil then obj.Enabled = props.Enabled end
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
    -- دالة الاستنساخ المطابق 100% (بدون فيزياء أو تشوهات)
    -- ==========================================
    local function ApplyPerfectClone(sourceChar)
        local myChar = lp.Character
        if not myChar or not sourceChar then return end

        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        local sourceHum = sourceChar:FindFirstChildOfClass("Humanoid")
        if not myHum or not sourceHum then return end

        if myHum.RigType ~= sourceHum.RigType then
            Notify("Cryptic Hub ⚠️", "لا يمكن النسخ: نوع الجسم مختلف (R6 / R15)!")
            return
        end

        RestoreOriginalState()
        SaveOriginalState(myChar)

        -- 1. مطابقة حجم جسمك مع الهدف لمنع التشوهات والمربعات
        local scales = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
        for _, scale in ipairs(scales) do
            local sVal = sourceHum:FindFirstChild(scale)
            local tVal = myHum:FindFirstChild(scale)
            if sVal and tVal and sVal:IsA("NumberValue") and tVal:IsA("NumberValue") then 
                tVal.Value = sVal.Value 
            end
        end
        
        task.wait(0.05) -- انتظار لتطبيق الحجم الجديد

        -- 2. إخفاء جسمك الأصلي (بالنسبة لك فقط)
        for _, v in ipairs(myChar:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Transparency = 1
            elseif v:IsA("Decal") and v.Name == "face" then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Highlight") or v:IsA("ForceField") then
                v.Enabled = false
            end
        end

        -- 3. استنساخ الهدف وتجهيزه
        sourceChar.Archivable = true
        fakeClone = sourceChar:Clone()
        fakeClone.Name = "CrypticSkin"

        -- 4. إبقاء العقل لظهور الملابس، لكن مع شلّه ومسح الرقصات لمنع الحركات الغريبة!
        local fakeHum = fakeClone:FindFirstChildOfClass("Humanoid")
        if fakeHum then
            fakeHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            fakeHum.PlatformStand = true -- يمنعه من الوقوف أو المشي لوحده
            
            -- مسح المحرك الحركي لمنع أي رقصة من التكرار
            local animator = fakeHum:FindFirstChildOfClass("Animator")
            if animator then animator:Destroy() end 
            
            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                pcall(function() fakeHum:SetStateEnabled(state, false) end)
            end
        end

        -- 5. تنظيف الدمية من الفيزياء والمفاصل لكي لا تجمد حركتك
        local syncPairs = {}
        for _, v in ipairs(fakeClone:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Tool") or v:IsA("BodyMover") or v:IsA("BodyVelocity") then
                v:Destroy()
            elseif v:IsA("BasePart") then
                v.CanCollide = false
                v.Massless = true
                v.CanTouch = false
                v.CanQuery = false
                if v.Name == "HumanoidRootPart" then v.Transparency = 1 end
                
                -- ربط قطع الدمية بقطع جسمك لتتبعها بسلاسة تامة
                local myPart = myChar:FindFirstChild(v.Name)
                if myPart and myPart:IsA("BasePart") then
                    v.Anchored = true -- تجميد القطعة فيزيائياً
                    table.insert(syncPairs, {Fake = v, My = myPart})
                end
            end
        end

        -- إبقاء الإكسسوارات حرة لتتحرك بشكل طبيعي مع الجسم
        for _, acc in ipairs(fakeClone:GetChildren()) do
            if acc:IsA("Accessory") then
                local handle = acc:FindFirstChild("Handle")
                if handle then
                    handle.Anchored = false
                    handle.CanCollide = false
                end
            end
        end

        myHum.DisplayName = sourceHum.DisplayName
        fakeClone.Parent = workspace.CurrentCamera -- نضعه في الكاميرا لمنع الأخطاء

        -- 6. نظام المزامنة البصرية (الدمية تنسخ مكانك وحركتك 60 مرة في الثانية)
        if syncConnection then syncConnection:Disconnect() end
        syncConnection = RunService.RenderStepped:Connect(function()
            if not myChar or not fakeClone or not myChar.Parent then
                if syncConnection then syncConnection:Disconnect() end
                return
            end
            
            -- نقل كل قطعة من الدمية لمكان قطعتك بالضبط! (حركتك هي التي تقود السكن)
            for _, pair in ipairs(syncPairs) do
                if pair.Fake and pair.My then
                    pair.Fake.CFrame = pair.My.CFrame
                end
            end
        end)
    end

    -- ==========================================
    -- بناء الواجهة
    -- ==========================================
    Tab:AddLabel("⚠️ الميزة لك فقط (باقي السيرفر يشوفك طبيعي)")

    local PlayerDropdown = Tab:AddPlayerSelector("اختر اللاعب / Select Player", "ابحث عن لاعب / Search...", function(selected)
        targetPlayer = (typeof(selected) == "Instance" and selected:IsA("Player")) and selected or nil
        
        if isToggleOn and targetPlayer and targetPlayer.Character then
            pcall(function()
                ApplyPerfectClone(targetPlayer.Character)
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
                ApplyPerfectClone(targetPlayer.Character)
                Notify("Cryptic Hub 🎭", "✅ تم النسخ! الملابس كاملة والحركة حرة!")
            end)
        else
            pcall(function()
                RestoreOriginalState()
                Notify("Cryptic Hub 🔄", "✅ تم استرجاع سكنك الأصلي!")
            end)
        end
    end)

    lp.CharacterAdded:Connect(function()
        if syncConnection then syncConnection:Disconnect(); syncConnection = nil end
        if fakeClone then fakeClone:Destroy(); fakeClone = nil end
        originalState = nil 
        
        task.delay(1, function()
            if isToggleOn and targetPlayer and targetPlayer.Character then
                ApplyPerfectClone(targetPlayer.Character)
            end
        end)
    end)

    Tab:AddLine()
end
