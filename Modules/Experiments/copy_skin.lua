-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (نظام الهولوغرام الخفي - Anti-Fly) ]]
-- المطور: يامي | الوصف: يظهر للجميع سكني العادي، وأنا أرى الهدف بدون أي طيران أو لاق

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
    -- نظام إخفاء شخصيتك (محلياً فقط - الجميع سيراك طبيعي)
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
    -- نظام الهولوغرام الخالي من الفيزياء (لمنع الطيران والتشوه)
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

        if syncConnection then syncConnection:Disconnect(); syncConnection = nil end
        if fakeClone then fakeClone:Destroy(); fakeClone = nil end

        -- إخفاء جسمك في شاشتك فقط
        HideMyCharacter(myChar)

        sourceChar.Archivable = true
        fakeClone = sourceChar:Clone()
        fakeClone.Name = "CrypticLocalHologram"
        
        -- 🟢 مسح أي شيء قد يسبب طيران أو تجميد حركتك
        for _, v in ipairs(fakeClone:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Tool") or v:IsA("BodyMover") or v:IsA("BodyVelocity") or v:IsA("BodyPosition") or v:IsA("BodyGyro") or v:IsA("AlignPosition") or v:IsA("AlignOrientation") then
                v:Destroy()
            elseif v:IsA("BasePart") then
                -- تفريغ القطع من الفيزياء تماماً لكي لا تصطدم بك
                v.Anchored = false
                v.CanCollide = false
                v.Massless = true
                v.CanTouch = false
                v.CanQuery = false
            end
        end

        -- إيقاف عقل الهولوغرام لكي لا يتخذ أي حركة من تلقاء نفسه أو يعلق على رقصة
        local cloneHum = fakeClone:FindFirstChildOfClass("Humanoid")
        if cloneHum then
            cloneHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            cloneHum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
            cloneHum.PlatformStand = true
            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                pcall(function() cloneHum:SetStateEnabled(state, false) end)
            end
            pcall(function() cloneHum:ChangeState(Enum.HumanoidStateType.Physics) end)
            local animator = cloneHum:FindFirstChildOfClass("Animator")
            if animator then animator:Destroy() end 
        end

        local cloneRoot = fakeClone:WaitForChild("HumanoidRootPart", 5)
        if cloneRoot then cloneRoot.Anchored = true end
        
        -- وضعه في مجلد خاص لتجنب الأخطاء
        local folder = workspace:FindFirstChild("CrypticMorphs")
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = "CrypticMorphs"
            folder.Parent = workspace
        end
        fakeClone.Parent = folder

        -- استخراج العظام لربطها ببطاقة الجرافيكس (حركة لحظية بدون لاق)
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

        local myRoot = myChar:WaitForChild("HumanoidRootPart", 5)
        
        -- المزامنة الحية البصرية فقط (تأخذ حركتك وتطبقها على الدمية بدون فيزياء)
        syncConnection = RunService.RenderStepped:Connect(function()
            if not myChar or not fakeClone or not myRoot or not cloneRoot then
                if syncConnection then syncConnection:Disconnect() end
                return
            end

            -- نقل الدمية لمكانك
            cloneRoot.CFrame = myRoot.CFrame

            -- تطبيق حركتك (مشي، ركض، رقص) على الدمية
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
    Tab:AddLabel("⚠️ الميزة لك فقط (باقي السيرفر يشوفك طبيعي)")

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
                ApplyHologram(targetPlayer.Character)
                Notify("Cryptic Hub 🎭", "✅ تم النسخ بنجاح! حركتك حرة تماماً!")
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
