-- [[ Cryptic Hub - جاذب الأشياء (Blackhole Parts V2.0) ]]
-- المطور: أروى هوب | الوصف: سحب القطع الحرة بأمان مع تنظيف المغناطيس عند الإيقاف

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer

    local blackHoleActive = false
    local DescendantAddedConnection = nil
    local updateLoop = nil

    local function Notify(arText, enText)
        pcall(function() StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = arText .. "\n" .. enText, Duration = 3}) end)
    end

    -- ==========================================
    -- تجهيز نقطة الجذب
    -- ==========================================
    local Folder = Workspace:FindFirstChild("CrypticBringFolder") or Instance.new("Folder")
    Folder.Name = "CrypticBringFolder"
    Folder.Parent = Workspace
    
    local TargetPart = Instance.new("Part", Folder)
    local Attachment1 = Instance.new("Attachment", TargetPart)
    TargetPart.Anchored = true
    TargetPart.CanCollide = false
    TargetPart.Transparency = 1

    -- ==========================================
    -- اختراق حماية الشبكة (Network Ownership Bypass)
    -- ==========================================
    if not getgenv().CrypticNetworkBypass then
        getgenv().CrypticNetworkBypass = {
            BaseParts = {},
            Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
        }

        LocalPlayer.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            pcall(function()
                if sethiddenproperty then
                    sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                end
            end)
            for _, Part in pairs(getgenv().CrypticNetworkBypass.BaseParts) do
                if Part and Part.Parent and Part:IsDescendantOf(Workspace) then
                    Part.Velocity = getgenv().CrypticNetworkBypass.Velocity
                end
            end
        end)
    end

    -- دالة حماية للتأكد من أن القطعة لا تتبع لأي لاعب (لمنع سحب القبعات والأدوات)
    local function isPartOfAnyCharacter(part)
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and part:IsDescendantOf(p.Character) then
                return true
            end
        end
        return false
    end

    local function ForcePart(v)
        -- 🔴 فلتر الحماية الصارم: تجاهل أي شيء يخص اللاعبين
        if v:IsA("BasePart") and not v.Anchored and not isPartOfAnyCharacter(v) and v.Name ~= "Handle" then
            
            table.insert(getgenv().CrypticNetworkBypass.BaseParts, v)
            v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            v.CanCollide = false

            -- تنظيف مسبق لأي محركات
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

    -- دالة تنظيف القطع عند إيقاف الزر لترجع الفيزياء طبيعية
    local function CleanUpParts()
        for _, Part in pairs(getgenv().CrypticNetworkBypass.BaseParts) do
            if Part and Part.Parent then
                if Part:FindFirstChild("CrypticAlign") then Part.CrypticAlign:Destroy() end
                if Part:FindFirstChild("CrypticTorque") then Part.CrypticTorque:Destroy() end
                if Part:FindFirstChild("CrypticAtt") then Part.CrypticAtt:Destroy() end
                Part.CanCollide = true
                Part.CustomPhysicalProperties = nil -- إرجاع الوزن الطبيعي للقطعة
            end
        end
        getgenv().CrypticNetworkBypass.BaseParts = {}
    end

    -- ==========================================
    -- واجهة المستخدم (تحديد اللاعب والتفعيل)
    -- ==========================================
    local PlayerSelector = Tab:AddPlayerSelector("تحديد لاعب الهدف / Target Player", "اكتب بداية اليوزر... / Type username start...", function(selectedValue)
        local targetPlayer = nil
        
        if type(selectedValue) == "string" then
            local search = selectedValue:lower()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and string.sub(p.Name:lower(), 1, #search) == search then
                    targetPlayer = p
                    break 
                end
            end
        else
            targetPlayer = selectedValue
        end

        if targetPlayer then
            _G.CrypticExperimentTarget = targetPlayer
            PlayerSelector.SetText(targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")")
            Notify("🎯 تم التحديد", "Target: " .. targetPlayer.DisplayName)
        else
            _G.CrypticExperimentTarget = nil
            Notify("❌ خطأ", "اللاعب غير موجود!")
        end
    end)

    local function RefreshDropdown()
        local list = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(list, p) end
        end
        PlayerSelector.UpdateList(list)
    end
    RefreshDropdown()
    Players.PlayerAdded:Connect(RefreshDropdown)
    Players.PlayerRemoving:Connect(RefreshDropdown)

    Tab:AddToggle("سحب الأشياء للهدف / Bring Parts to Target", function(state)
        blackHoleActive = state
        
        if state then
            local targetPlayer = _G.CrypticExperimentTarget
            if not targetPlayer then
                Notify("⚠️ تنبيه", "الرجاء تحديد لاعب أولاً!")
                blackHoleActive = false
                return
            end

            Notify("🌪️ تفعيل الثقب الأسود", "جاري سحب الأشياء إلى: " .. targetPlayer.DisplayName)

            for _, v in ipairs(Workspace:GetDescendants()) do ForcePart(v) end

            DescendantAddedConnection = Workspace.DescendantAdded:Connect(function(v)
                if blackHoleActive then ForcePart(v) end
            end)

            updateLoop = RunService.RenderStepped:Connect(function()
                if blackHoleActive and _G.CrypticExperimentTarget and _G.CrypticExperimentTarget.Character then
                    local root = _G.CrypticExperimentTarget.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        Attachment1.WorldCFrame = root.CFrame
                    end
                end
            end)
        else
            Notify("🛑 توقف", "تم إيقاف الثقب الأسود وإرجاع القطع.")
            if DescendantAddedConnection then DescendantAddedConnection:Disconnect() end
            if updateLoop then updateLoop:Disconnect() end
            
            -- 🔴 هنا السر: مسح المغناطيس من كل القطع عند الإيقاف
            CleanUpParts()
        end
    end)
    
    Tab:AddLine()
end
