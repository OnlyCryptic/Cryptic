-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (نظام الهولوغرام النهائي 100%) ]]
-- المطور: يامي | الوصف: نسخ دقيق جداً بدون تشوهات (لا مربعات ولا تمصص) مع حركة طبيعية

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    local isToggleOn = false
    local originalProps = {}
    local syncConnection = nil 
    local fakeClone = nil

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 }) end)
    end

    -- ==========================================
    -- دوال إخفاء وإظهار شخصيتك الحقيقية
    -- ==========================================
    local function HideMyCharacter(char)
        originalProps = {}
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                originalProps[v] = { Transparency = v.Transparency }
                v.Transparency = 1
            elseif v:IsA("Decal") and v.Name == "face" then
                originalProps[v] = { Transparency = v.Transparency }
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Highlight") then
                originalProps[v] = { Enabled = v.Enabled }
                v.Enabled = false
            end
        end
    end

    local function ShowMyCharacter()
        for obj, props in pairs(originalProps) do
            if obj and obj.Parent then
                if props.Transparency ~= nil then obj.Transparency = props.Transparency end
                if props.Enabled ~= nil then obj.Enabled = props.Enabled end
            end
        end
        originalProps = {}
    end

    -- ==========================================
    -- دالة إنشاء الهولوغرام ومطابقة الحركة (بدون تشوه)
    -- ==========================================
    local function ApplyHologram(sourceChar)
        local myChar = lp.Character
        if not myChar or not sourceChar then return end

        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        local sourceHum = sourceChar:FindFirstChildOfClass("Humanoid")
        if not myHum or not sourceHum then return end

        if myHum.RigType ~= sourceHum.RigType then
            Notify("Cryptic Hub ⚠️", "لا يمكن النسخ: نوع الجسم مختلف (R6 / R15)!\nRig types must match!")
            return
        end

        -- تنظيف أي نسخ سابقة
        if syncConnection then syncConnection:Disconnect(); syncConnection = nil end
        if fakeClone then fakeClone:Destroy(); fakeClone = nil end

        -- 1. إخفاء جسمك الحقيقي
        HideMyCharacter(myChar)

        -- 2. إنشاء الهولوغرام المطابق 100% للهدف
        sourceChar.Archivable = true
        fakeClone = sourceChar:Clone()
        fakeClone.Name = "LocalHologram"
        
        -- إيقاف فيزياء وبرمجيات الهولوغرام لكي لا يتحرك من تلقاء نفسه أو يسبب تعليق
        for _, v in ipairs(fakeClone:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") then
                v:Destroy()
            elseif v:IsA("BasePart") then
                v.Anchored = false
                v.CanCollide = false
                v.Massless = true
            end
        end

        local cloneHum = fakeClone:FindFirstChildOfClass("Humanoid")
        if cloneHum then
            cloneHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            cloneHum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
            cloneHum.PlatformStand = true
            local animator = cloneHum:FindFirstChildOfClass("Animator")
            if animator then animator:Destroy() end -- مسح العقل المحرك لمنع الرقصات المعلقة
        end

        -- تثبيت مركز الهولوغرام لكي نتحكم به بالكود
        local cloneRoot = fakeClone:WaitForChild("HumanoidRootPart")
        cloneRoot.Anchored = true
        
        -- وضعه في الكاميرا لكي تراه أنت فقط ولا يتأثر بمؤثرات الماب
        fakeClone.Parent = workspace.CurrentCamera

        -- 3. تجهيز قائمة العظام لربط حركة الهولوغرام بحركتك (بسرعة فائقة وبدون لاق)
        local motorPairs = {}
        for _, myDesc in ipairs(myChar:GetDescendants()) do
            if myDesc:IsA("Motor6D") then
                local clonePart = fakeClone:FindFirstChild(myDesc.Parent.Name)
                if clonePart then
                    local cloneMotor = clonePart:FindFirstChild(myDesc.Name)
                    if cloneMotor and cloneMotor:IsA("Motor6D") then
                        table.insert(motorPairs, { MyMotor = myDesc, CloneMotor = cloneMotor })
                    end
                end
            end
        end

        -- 4. الحلقة السحرية: تحديث مكان الهولوغرام وحركته 60 مرة في الثانية!
        local myRoot = myChar:WaitForChild("HumanoidRootPart")
        syncConnection = RunService.RenderStepped:Connect(function()
            if not myChar or not fakeClone or not myRoot or not cloneRoot then
                if syncConnection then syncConnection:Disconnect() end
                return
            end

            -- أ. جعل الهولوغرام يتبع مكانك بالضبط
            cloneRoot.CFrame = myRoot.CFrame

            -- ب. جعل الهولوغرام يقلد حركة مفاصلك (المشي، الركض، الرقص) لحظياً
            for _, pair in ipairs(motorPairs) do
                if pair.CloneMotor and pair.MyMotor then
                    pair.CloneMotor.Transform = pair.MyMotor.Transform
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
                ApplyHologram(targetPlayer.Character)
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

    Tab:AddToggle("تفعيل السكن المستنسخ / Copy. Skin", function(state)
        isToggleOn = state
        local myChar = lp.Character
        if not myChar then return end

        if state then
            if not targetPlayer or not targetPlayer.Character then
                Notify("Cryptic Hub ⚠️", "يرجى اختيار لاعب موجود باللعبة!\nPlease select a valid player!")
                return
            end
            
            pcall(function()
                ApplyHologram(targetPlayer.Character)
                Notify("Cryptic Hub 🎭", "✅ تم النسخ 100%! الجسم سليم وحركتك طبيعية!")
            end)
        else
            pcall(function()
                if syncConnection then syncConnection:Disconnect(); syncConnection = nil end
                if fakeClone then fakeClone:Destroy(); fakeClone = nil end
                ShowMyCharacter()
                Notify("Cryptic Hub 🔄", "✅ تم استرجاع سكنك الأصلي!")
            end)
        end
    end)

    lp.CharacterAdded:Connect(function()
        if syncConnection then syncConnection:Disconnect(); syncConnection = nil end
        if fakeClone then fakeClone:Destroy(); fakeClone = nil end
        originalProps = {}
        
        task.delay(1, function()
            if isToggleOn and targetPlayer and targetPlayer.Character then
                ApplyHologram(targetPlayer.Character)
            end
        end)
    end)

    Tab:AddLine()
end
