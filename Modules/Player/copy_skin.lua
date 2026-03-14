-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (نظام CFrame السلس 100%) ]]
-- المطور: يامي | الوصف: نسخ الجسم والمشية بدون أي تأثير على حركتك الفيزيائية

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    local isToggleOn = false
    local originalState = nil 
    local syncConnection = nil 

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 }) end)
    end

    -- ==========================================
    -- نظام حفظ واسترجاع حالتك الأصلية
    -- ==========================================
    local function SaveOriginalState(char)
        if originalState then return end
        originalState = { Props = {}, DisplayName = lp.DisplayName }

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then originalState.DisplayName = hum.DisplayName end

        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                originalState.Props[v] = { Transparency = v.Transparency }
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Highlight") or v:IsA("ForceField") then
                originalState.Props[v] = { Enabled = v.Enabled }
            end
        end
    end

    local function RestoreOriginalState()
        local myChar = lp.Character
        if not myChar or not originalState then return end

        if syncConnection then syncConnection:Disconnect(); syncConnection = nil end
        local morph = myChar:FindFirstChild("FakeMorph")
        if morph then morph:Destroy() end

        for obj, props in pairs(originalState.Props) do
            if obj and obj.Parent then
                if props.Transparency ~= nil then obj.Transparency = props.Transparency end
                if props.Enabled ~= nil then obj.Enabled = props.Enabled end
            end
        end

        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then hum.DisplayName = originalState.DisplayName end
    end

    -- ==========================================
    -- دالة التزامن البصري (CFrame Sync)
    -- ==========================================
    local function ApplyPuppetMorph(sourceChar)
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

        -- 1. إخفاء جسمك الأصلي بالكامل
        for _, v in ipairs(myChar:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Transparency = 1
            elseif v:IsA("Decal") and v.Name == "face" then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Highlight") or v:IsA("ForceField") then
                v.Enabled = false
            end
        end

        -- 2. استنساخ الهدف ليكون الدمية
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

        -- تنظيف الدمية وإلغاء مفاصل الجسم حتى لا تسبب تجمد الحركة
        for _, v in ipairs(morph:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") then
                v:Destroy()
            elseif v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("WeldConstraint") then
                -- لا نحذف لحامات الإكسسوارات لكي لا تسقط
                if not v:FindFirstAncestorOfClass("Accessory") then
                    v:Destroy()
                end
            end
        end

        -- 3. تجهيز أجزاء الدمية لعملية التتبع السلس
        local syncPairs = {}
        for _, myPart in ipairs(myChar:GetChildren()) do
            if myPart:IsA("BasePart") then
                local morphPart = morph:FindFirstChild(myPart.Name)
                if morphPart and morphPart:IsA("BasePart") then
                    table.insert(syncPairs, {Morph = morphPart, My = myPart})
                    morphPart.Anchored = true -- تجميد الدمية فيزيائياً
                    morphPart.CanCollide = false
                    morphPart.Massless = true
                    if morphPart.Name == "HumanoidRootPart" then morphPart.Transparency = 1 end
                end
            end
        end

        -- تجهيز الإكسسوارات لكي تتبع الجسم
        for _, acc in ipairs(morph:GetChildren()) do
            if acc:IsA("Accessory") then
                local handle = acc:FindFirstChild("Handle")
                if handle then
                    handle.Anchored = false
                    handle.CanCollide = false
                    handle.Massless = true
                end
            end
        end

        myHum.DisplayName = sourceHum.DisplayName
        morph.Parent = myChar

        -- 4. التزامن البصري المرعب (RenderStepped لمطابقة الحركة 100%)
        if syncConnection then syncConnection:Disconnect() end
        syncConnection = RunService.RenderStepped:Connect(function()
            if not myChar or not morph or not myChar.Parent then
                if syncConnection then syncConnection:Disconnect() end
                return
            end
            -- نقل كل قطعة من الدمية لمكان قطعتك المخفية بشكل لحظي وبدون فيزياء!
            for _, pair in ipairs(syncPairs) do
                if pair.Morph and pair.My then
                    pair.Morph.CFrame = pair.My.CFrame
                end
            end
        end)
    end

    -- ==========================================
    -- بناء الواجهة
    -- ==========================================
    Tab:AddLabel("⚠️ الميزة لك فقط / Only you can see the skin")

    local PlayerDropdown = Tab:AddPlayerSelector("اختر اللاعب / Select Player", "ابحث عن لاعب / Search...", function(selected)
        targetPlayer = (typeof(selected) == "Instance" and selected:IsA("Player")) and selected or nil
        
        if isToggleOn and targetPlayer and targetPlayer.Character then
            pcall(function()
                ApplyPuppetMorph(targetPlayer.Character)
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
                ApplyPuppetMorph(targetPlayer.Character)
                Notify("Cryptic Hub 🎭", "✅ تم النسخ! حركتك ستظل طبيعية!\nSkin copied seamlessly!")
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
        if syncConnection then syncConnection:Disconnect(); syncConnection = nil end
        
        task.delay(1, function()
            if isToggleOn and targetPlayer and targetPlayer.Character then
                ApplyPuppetMorph(targetPlayer.Character)
            end
        end)
    end)

    Tab:AddLine()
end
