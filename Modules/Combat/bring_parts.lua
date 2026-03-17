-- [[ Cryptic Hub - تطيره بالبلوكات (Fling with Parts V5.0) ]]
-- المطور: أروى هوب | الوصف: سحب القطع وتطير الهدف (مربوط بالقائمة الموحدة)

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer

    local blackHoleActive = false
    local DescendantAddedConnection = nil
    local updateLoop = nil
    local networkLoop = nil 

    -- دالة الإشعارات المزدوجة
    local function Notify(arText, enText)
        pcall(function() StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = arText .. "\n" .. enText, Duration = 3}) end)
    end

    -- ==========================================
    -- تجهيز نقطة الجذب في الماب
    -- ==========================================
    local Folder = Workspace:FindFirstChild("CrypticBringFolder") or Instance.new("Folder")
    Folder.Name = "CrypticBringFolder"
    Folder.Parent = Workspace
    
    local TargetPart = Workspace:FindFirstChild("CrypticTargetPart") or Instance.new("Part")
    TargetPart.Name = "CrypticTargetPart"
    TargetPart.Parent = Folder
    local Attachment1 = TargetPart:FindFirstChild("Attachment1") or Instance.new("Attachment", TargetPart)
    Attachment1.Name = "Attachment1"
    TargetPart.Anchored = true
    TargetPart.CanCollide = false
    TargetPart.Transparency = 1

    -- تهيئة جدول القطع
    if not getgenv().CrypticNetworkBypass then
        getgenv().CrypticNetworkBypass = { BaseParts = {} }
    end

    -- ==========================================
    -- الفلتر الفيزيائي الصارم لحماية اللاعبين
    -- ==========================================
    local function isSafeToGrab(part)
        if not part:IsA("BasePart") then return false end
        if part.Anchored then return false end
        if part.Transparency == 1 then return false end 
        
        local root = part.AssemblyRootPart
        if root and root.Parent and root.Parent:FindFirstChildOfClass("Humanoid") then return false end
        if part:FindFirstAncestorWhichIsA("Accessory") then return false end
        
        local tool = part:FindFirstAncestorWhichIsA("Tool")
        if tool and tool.Parent and tool.Parent:FindFirstChildOfClass("Humanoid") then return false end

        if LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character) then return false end

        return true
    end

    -- ==========================================
    -- دالة زرع المغناطيس في القطع
    -- ==========================================
    local function ForcePart(v)
        if isSafeToGrab(v) then
            if not table.find(getgenv().CrypticNetworkBypass.BaseParts, v) then
                table.insert(getgenv().CrypticNetworkBypass.BaseParts, v)
            end
            
            v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            v.CanCollide = false

            for _, x in ipairs(v:GetChildren()) do
                if x:IsA("BodyMover") or x:IsA("RocketPropulsion") or x:IsA("AlignPosition") or x:IsA("Torque") or x:IsA("Attachment") then
                    x:Destroy()
                end
            end
            
            local Torque = Instance.new("Torque", v)
            Torque.Name = "CrypticTorque"
            Torque.Torque = Vector3.new(100000, 100000, 100000)
            
            local AlignPosition = Instance.new("AlignPosition", v)
            AlignPosition.Name = "CrypticAlign"
            local Attachment2 = Instance.new("Attachment", v)
            Attachment2.Name = "CrypticAtt"
            
            Torque.Attachment0 = Attachment2
            AlignPosition.MaxForce = math.huge
            AlignPosition.MaxVelocity = math.huge
            AlignPosition.Responsiveness = 200
            AlignPosition.Attachment0 = Attachment2
            AlignPosition.Attachment1 = Attachment1
        end
    end

    -- ==========================================
    -- دالة التنظيف (إنهاء الزلزال وتصفير السرعات)
    -- ==========================================
    local function CleanUpParts()
        for _, Part in pairs(getgenv().CrypticNetworkBypass.BaseParts) do
            if Part and Part.Parent then
                if Part:FindFirstChild("CrypticAlign") then Part.CrypticAlign:Destroy() end
                if Part:FindFirstChild("CrypticTorque") then Part.CrypticTorque:Destroy() end
                if Part:FindFirstChild("CrypticAtt") then Part.CrypticAtt:Destroy() end
                
                Part.Velocity = Vector3.new(0, 0, 0)
                Part.RotVelocity = Vector3.new(0, 0, 0)
                
                Part.CanCollide = true
                Part.CustomPhysicalProperties = nil 
            end
        end
        getgenv().CrypticNetworkBypass.BaseParts = {}
    end

    -- ==========================================
    -- زر التفعيل الأساسي (مربوط بقائمة الاستهداف)
    -- ==========================================
    Tab:AddToggle("تطيره بالبلوكات / Fling with Parts", function(state)
        blackHoleActive = state
        
        if state then
            -- 🔴 الاعتماد المباشر على المتغير العام من قائمة تحديد اللاعب
            local targetPlayer = _G.ArwaTarget
            
            if not targetPlayer then
                Notify("⚠️ تنبيه / Warning", "الرجاء تحديد لاعب من القائمة أولاً!\nPlease select a player first!")
                blackHoleActive = false
                return
            end

            Notify("🌪️ هجوم القطع / Parts Attack", "جاري تطير: " .. targetPlayer.DisplayName .. "\nFlinging: " .. targetPlayer.DisplayName)

            -- تشغيل لوب الشبكة بأمان لمنع نوم القطع
            if not networkLoop then
                networkLoop = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        if sethiddenproperty then
                            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                        end
                    end)
                    for _, Part in pairs(getgenv().CrypticNetworkBypass.BaseParts) do
                        if Part and Part.Parent and Part.Velocity.Magnitude < 1 then
                            Part.Velocity = Vector3.new(0, -1, 0)
                        end
                    end
                end)
            end

            -- سحب القطع الموجودة والجديدة
            for _, v in ipairs(Workspace:GetDescendants()) do ForcePart(v) end

            DescendantAddedConnection = Workspace.DescendantAdded:Connect(function(v)
                if blackHoleActive then ForcePart(v) end
            end)

            -- متابعة الهدف بالمغناطيس
            updateLoop = RunService.RenderStepped:Connect(function()
                -- 🔴 تحديث مستمر بناءً على اللاعب المحدد
                if blackHoleActive and _G.ArwaTarget and _G.ArwaTarget.Character then
                    local root = _G.ArwaTarget.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        Attachment1.WorldCFrame = root.CFrame
                    end
                end
            end)
        else
            Notify("🛑 توقف / Stopped", "تم إرجاع القطع لطبيعتها.\nParts returned to normal.")
            
            -- إيقاف كل شيء
            if DescendantAddedConnection then DescendantAddedConnection:Disconnect() DescendantAddedConnection = nil end
            if updateLoop then updateLoop:Disconnect() updateLoop = nil end
            if networkLoop then networkLoop:Disconnect() networkLoop = nil end
            
            CleanUpParts()
        end
    end)
    
    Tab:AddLine()
end
