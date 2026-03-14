-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (نظام التزامن العظمي 100%) ]]
-- المطور: يامي | الوصف: نسخ شكل الجسم بدقة متناهية بدون تشوه باستخدام Motor6D Sync

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    local isToggleOn = false
    local originalState = nil 
    local syncConnection = nil -- متغير للتحكم في حلقة التزامن

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

        -- تدمير الدمية
        local morph = myChar:FindFirstChild("FakeMorph")
        if morph then morph:Destroy() end
        if syncConnection then syncConnection:Disconnect(); syncConnection = nil end

        -- إرجاع ألوانك ومؤثراتك
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
    -- دالة التزامن العظمي (نسخ الجسم والحركة بدون تشوه)
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

        -- 2. استنساخ الهدف وتجهيز الدمية
        sourceChar.Archivable = true
        local morph = sourceChar:Clone()
        morph.Name = "FakeMorph"

        -- تجميد عقل الدمية لكي لا تتعارض مع حركتك
        local morphHum = morph:FindFirstChildOfClass("Humanoid")
        if morphHum then
            morphHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            morphHum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
            morphHum.PlatformStand = true
            local animator = morphHum:FindFirstChildOfClass("Animator")
            if animator then animator:Destroy() end
        end

        -- تنظيف الدمية من السكربتات وإلغاء التصادم
        for _, v in ipairs(morph:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") then
                v:Destroy()
            elseif v:IsA("BasePart") then
                v.CanCollide = false
                v.Massless = true
                v.Anchored = false
                if v.Name == "HumanoidRootPart" then v.Transparency = 1 end
            end
        end

        -- 3. اللحام المركزي فقط (للحفاظ على أبعاد الجسم)
        local rootWeld = Instance.new("Weld")
        rootWeld.Name = "CenterWeld"
        rootWeld.Part0 = myChar:WaitForChild("HumanoidRootPart")
        rootWeld.Part1 = morph:WaitForChild("HumanoidRootPart")
        rootWeld.C0 = CFrame.new()
        rootWeld.C1 = CFrame.new()
        rootWeld.Parent = morph:WaitForChild("HumanoidRootPart")

        myHum.DisplayName = sourceHum.DisplayName
        morph.Parent = myChar

        -- 4. التزامن السحري للعظام (نقل المشية والحركة لحظياً)
        if syncConnection then syncConnection:Disconnect() end
        syncConnection = RunService.Stepped:Connect(function()
            if not myChar or not morph or not myChar.Parent then
                if syncConnection then syncConnection:Disconnect() end
                return
            end
            
            -- مطابقة زوايا المفاصل (Motor6D) لتتحرك الدمية كأنها أنت
            for _, myMotor in ipairs(myChar:GetDescendants()) do
                if myMotor:IsA("Motor6D") and myMotor.Parent then
                    local morphPart = morph:FindFirstChild(myMotor.Parent.Name)
                    if morphPart then
                        local morphMotor = morphPart:FindFirstChild(myMotor.Name)
                        if morphMotor and morphMotor:IsA("Motor6D") then
                            morphMotor.Transform = myMotor.Transform
                        end
                    end
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
                Notify("Cryptic Hub 🎭", "✅ تم نسخ الجسم 100% بدون تشويه!\nPerfect body copy applied!")
            end)
        else
            pcall(function()
                RestoreOriginalState()
                Notify("Cryptic Hub 🔄", "✅ تم استرجاع سكنك الأصلي!\nOriginal skin restored!")
            end)
        end
    end)

    lp.CharacterAdded:Connect(function(newChar)
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
