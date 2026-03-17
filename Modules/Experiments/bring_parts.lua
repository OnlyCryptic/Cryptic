-- [[ Cryptic Hub - جاذب الأشياء (Blackhole Parts) ]]
-- المطور: يامي | الوصف: سحب كل القطع الحرة في الماب وقذفها نحو اللاعب المستهدف

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
    -- تجهيز نقطة الجذب والمغناطيس
    -- ==========================================
    local Folder = Instance.new("Folder")
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
                if Part:IsDescendantOf(Workspace) then
                    Part.Velocity = getgenv().CrypticNetworkBypass.Velocity
                end
            end
        end)
    end

    local function ForcePart(v)
        -- التأكد أن القطعة حرة (غير مثبتة) وليست جزءاً من لاعب أو خريطة ثابتة
        if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
            
            -- تسجيل القطعة لتهكير الشبكة
            table.insert(getgenv().CrypticNetworkBypass.BaseParts, v)
            v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            v.CanCollide = false

            -- تنظيف المحركات القديمة
            for _, x in ipairs(v:GetChildren()) do
                if x:IsA("BodyMover") or x:IsA("RocketPropulsion") or x:IsA("AlignPosition") or x:IsA("Torque") or x:IsA("Attachment") then
                    x:Destroy()
                end
            end
            
            -- زرع المحركات الجديدة للتوجه للهدف
            local Torque = Instance.new("Torque", v)
            Torque.Torque = Vector3.new(100000, 100000, 100000)
            
            local AlignPosition = Instance.new("AlignPosition", v)
            local Attachment2 = Instance.new("Attachment", v)
            
            Torque.Attachment0 = Attachment2
            AlignPosition.MaxForce = math.huge
            AlignPosition.MaxVelocity = math.huge
            AlignPosition.Responsiveness = 200
            AlignPosition.Attachment0 = Attachment2
            AlignPosition.Attachment1 = Attachment1
        end
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

    -- تحديث قائمة اللاعبين
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

    -- زر التفعيل
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

            -- سحب كل القطع الموجودة حالياً
            for _, v in ipairs(Workspace:GetDescendants()) do ForcePart(v) end

            -- سحب أي قطعة جديدة تظهر في الماب
            DescendantAddedConnection = Workspace.DescendantAdded:Connect(function(v)
                if blackHoleActive then ForcePart(v) end
            end)

            -- تحديث المغناطيس ليكون دائماً عند اللاعب المستهدف
            updateLoop = RunService.RenderStepped:Connect(function()
                if blackHoleActive and _G.CrypticExperimentTarget and _G.CrypticExperimentTarget.Character then
                    local root = _G.CrypticExperimentTarget.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        Attachment1.WorldCFrame = root.CFrame
                    end
                end
            end)
        else
            Notify("🛑 توقف", "تم إيقاف الثقب الأسود.")
            if DescendantAddedConnection then DescendantAddedConnection:Disconnect() end
            if updateLoop then updateLoop:Disconnect() end
            
            -- تفريغ القطع من السيطرة
            getgenv().CrypticNetworkBypass.BaseParts = {}
        end
    end)
    
    Tab:AddLine()
end
