-- [[ Cryptic Hub - جاذب الأشياء (Blackhole Parts V3.0 - Anti-Drift) ]]
-- المطور: أروى هوب | الوصف: فلتر فيزيائي صارم يمنع انزلاق اللاعب أو سحب أدواته

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

    -- 🔴 الفلتر الفيزيائي الصارم: يمنع سحب أي شيء يخص اللاعبين
    local function isSafeToGrab(part)
        if not part:IsA("BasePart") then return false end
        if part.Anchored then return false end
        if part.Transparency == 1 then return false end -- تجاهل القطع المخفية (تكون غالباً Hitboxes)
        
        -- الفحص العميق عبر جذور الفيزياء (AssemblyRootPart)
        local root = part.AssemblyRootPart
        if root and root.Parent and root.Parent:FindFirstChildOfClass("Humanoid") then 
            return false 
        end
        
        -- تجاهل الإكسسوارات بشكل صريح
        if part:FindFirstAncestorWhichIsA("Accessory") then return false end
        
        -- تجاهل الأدوات (Tools) الموجودة في يد أي لاعب
        local tool = part:FindFirstAncestorWhichIsA("Tool")
        if tool and tool.Parent and tool.Parent:FindFirstChildOfClass("Humanoid") then return false end

        -- تجاهل قطع شخصيتك بشكل مباشر
        if LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character) then return false end

        return true
    end

    local function ForcePart(v)
        if isSafeToGrab(v) then
            table.insert(getgenv().CrypticNetworkBypass.BaseParts, v)
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

    local function CleanUpParts()
        for _, Part in pairs(getgenv().CrypticNetworkBypass.BaseParts) do
            if Part and Part.Parent then
                if Part:FindFirstChild("CrypticAlign") then Part.CrypticAlign:Destroy() end
                if Part:FindFirstChild("CrypticTorque") then Part.CrypticTorque:Destroy() end
                if Part:FindFirstChild("CrypticAtt") then Part.CrypticAtt:Destroy() end
                Part.CanCollide = true
                Part.CustomPhysicalProperties = nil 
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

    Tab:AddToggle("سحب الأشياء للهدف ./ Bring Parts to Target", function(state)
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
            CleanUpParts()
        end
    end)
    
    Tab:AddLine()
end
