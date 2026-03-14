-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (نظام الخيال الحر 100%) ]]
-- المطور: يامي | الوصف: تحكم طبيعي جداً + عدم تداخل فيزيائي + نسخ مثالي لشكل الجسم

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
    -- نظام إخفاء شخصيتك (الجميع يراك طبيعياً)
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
    -- نظام الخيال الحر (بدون أي تأثير على تحكمك)
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

        HideMyCharacter(myChar)

        sourceChar.Archivable = true
        fakeClone = sourceChar:Clone()
        fakeClone.Name = "CrypticGhostClone"
        
        -- 🟢 تدمير أي فيزياء ومنع التصادم القطعي
        for _, v in ipairs(fakeClone:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Tool") or v:IsA("BodyMover") or v:IsA("BodyVelocity") or v:IsA("AlignPosition") then
                v:Destroy()
            elseif v:IsA("BasePart") then
                v.Anchored = false
                v.CanCollide = false
                v.Massless = true
                v.CanTouch = false
                v.CanQuery = false
                
                -- 🟢 السر هنا: منع التصادم بين الدمية وجسمك نهائياً لكي لا تدفعك
                for _, myPart in ipairs(myChar:GetDescendants()) do
                    if myPart:IsA("BasePart") then
                        local ncc = Instance.new("NoCollisionConstraint")
                        ncc.Part0 = v
                        ncc.Part1 = myPart
                        ncc.Parent = v
                    end
                end
            end
        end

        -- شل حركة الدمية وبرمجتها لتصبح مجرد صورة
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
        
        -- وضع الدمية في الكاميرا لكي لا تتدخل في الماب
        fakeClone.Parent = workspace.CurrentCamera
        
        -- التأكد من أن الكاميرا تتبع جسمك الحقيقي لتستمر بالتحكم بشكل طبيعي
        workspace.CurrentCamera.CameraSubject = myHum

        -- استخراج مفاصل الحركة
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
        
        -- المزامنة البصرية (الدمية تلحقك بدون فيزياء)
        syncConnection = RunService.RenderStepped:Connect(function()
            if not myChar or not fakeClone or not myRoot or not cloneRoot then
                if syncConnection then syncConnection:Disconnect() end
                return
            end

            -- نقل مركز الدمية لمكانك
            cloneRoot.CFrame = myRoot.CFrame

            -- نقل زوايا المشي والركض (Animation Sync)
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
                Notify("Cryptic Hub 🎭", "✅ تم النسخ بنجاح! تحكمك طبيعي 100%!")
            end)
        else
            pcall(function()
                if syncConnection then syncConnection:Disconnect(); syncConnection = nil end
                if fakeClone then fakeClone:Destroy(); fakeClone = nil end
                ShowMyCharacter()
                workspace.CurrentCamera.CameraSubject = myChar:FindFirstChildOfClass("Humanoid")
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
