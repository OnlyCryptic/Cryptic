-- [[ Cryptic Hub - Module: Fling Things and People (FTAP) ]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Global Connections
local autoFlingConn = nil
local antiGrabConn = nil
local antiRagdollConn = nil
local speedConn = nil
local jumpConn = nil

return {
    Name = "Fling Things and People",

    Render = function(tab)
        ------------------------------------------------------------------------
        -- 1. حالة الجلسة
        ------------------------------------------------------------------------
        tab:AddParagraph("Cryptic Hub | FTAP", "نظام الحماية والمحرك المطور")

        local statusLabel = tab:AddLabel("الحالة: جاري المراقبة...")

        local function updateStatus()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hp = hum and math.floor(hum.Health) or 0
            local maxHp = hum and math.floor(hum.MaxHealth) or 100
            
            statusLabel:SetText(string.format("الصحة: %d/%d | اللاعبون: %d", hp, maxHp, #Players:GetPlayers()))
        end

        ------------------------------------------------------------------------
        -- 2. التطيير الخارق التلقائي (Auto Super Fling Toggle)
        ------------------------------------------------------------------------
        tab:AddParagraph("ميزات التطيير / Fling System", "تفعيل التطيير التلقائي لأي جسم ممسوك")

        local autoFlingEnabled = false
        tab:AddToggle("تطيير خارق تلقائي / Auto Super Fling", false, function(enabled)
            autoFlingEnabled = enabled
            if enabled then
                if not autoFlingConn then
                    autoFlingConn = RunService.Heartbeat:Connect(function()
                        if not autoFlingEnabled then return end
                        
                        local grabParts = Workspace:FindFirstChild("GrabParts")
                        if grabParts then
                            for _, grab in ipairs(grabParts:GetChildren()) do
                                local weld = grab:FindFirstChildOfClass("WeldConstraint") or grab:FindFirstChildOfClass("Weld")
                                if weld and weld.Part1 then
                                    local targetPart = weld.Part1
                                    local char = LocalPlayer.Character
                                    -- التأكد من أن الجسم الممسوك لا يتبع لشخصيتك
                                    if not (char and targetPart:IsDescendantOf(char)) then
                                        targetPart.AssemblyLinearVelocity = Vector3.new(0, 35000, 0)
                                        targetPart.AssemblyAngularVelocity = Vector3.new(15000, 15000, 15000)
                                    end
                                end
                            end
                        end
                    end)
                end
            elseif autoFlingConn then
                autoFlingConn:Disconnect()
                autoFlingConn = nil
            end
        end)

        ------------------------------------------------------------------------
        -- 3. إصلاح الحمايات (Anti-Grab & Anti-Ragdoll)
        ------------------------------------------------------------------------
        tab:AddParagraph("الحماية المتقدمة / Advanced Protections", "إصلاح كامل لآليات المسك والسقوط")

        -- منع المسك الحقيقي (Anti-Grab)
        tab:AddToggle("منع المسك / Anti-Grab (Fixed)", false, function(enabled)
            if enabled then
                if not antiGrabConn then
                    antiGrabConn = RunService.Heartbeat:Connect(function()
                        local char = LocalPlayer.Character
                        if not char then return end

                        -- 1. تدمير روابط المسك في مجلد GrabParts
                        local grabParts = Workspace:FindFirstChild("GrabParts")
                        if grabParts then
                            for _, grab in ipairs(grabParts:GetChildren()) do
                                for _, constraint in ipairs(grab:GetDescendants()) do
                                    if constraint:IsA("WeldConstraint") or constraint:IsA("Weld") or constraint:IsA("RopeConstraint") then
                                        if (constraint.Part0 and constraint.Part0:IsDescendantOf(char)) or 
                                           (constraint.Part1 and constraint.Part1:IsDescendantOf(char)) then
                                            constraint:Destroy()
                                        end
                                    end
                                end
                            end
                        end

                        -- 2. إزالة أي قيود حركية خارجية مجبرة على الشخصية
                        for _, obj in ipairs(char:GetDescendants()) do
                            if obj:IsA("WeldConstraint") or obj:IsA("RopeConstraint") or obj:IsA("NoCollisionConstraint") then
                                local p0 = obj.Part0
                                local p1 = obj.Part1
                                if (p0 and not p0:IsDescendantOf(char)) or (p1 and not p1:IsDescendantOf(char)) then
                                    obj:Destroy()
                                end
                            end
                        end
                    end)
                end
            elseif antiGrabConn then
                antiGrabConn:Disconnect()
                antiGrabConn = nil
            end
        end)

        -- منع السقوط والـ Ragdoll (Anti-Ragdoll)
        tab:AddToggle("منع السقوط / Anti-Ragdoll (Fixed)", false, function(enabled)
            if enabled then
                if not antiRagdollConn then
                    antiRagdollConn = RunService.Stepped:Connect(function()
                        local char = LocalPlayer.Character
                        if not char then return end

                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                        end

                        -- استعادة مفاصل الجسم الأصليّة وتعطيل قيود السقوط
                        for _, desc in ipairs(char:GetDescendants()) do
                            if desc:IsA("Motor6D") then
                                desc.Enabled = true
                            elseif desc:IsA("BallSocketConstraint") or desc:IsA("HingeConstraint") then
                                desc.Enabled = false
                            elseif desc:IsA("BoolValue") or desc:IsA("StringValue") then
                                if desc.Name:lower():find("ragdoll") or desc.Name:lower():find("stun") then
                                    desc.Value = false
                                end
                            end
                        end
                    end)
                end
            elseif antiRagdollConn then
                antiRagdollConn:Disconnect()
                antiRagdollConn = nil
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
                end
            end
        end)

        ------------------------------------------------------------------------
        -- 4. إضافات قدرات جديدة (New Strong Features)
        ------------------------------------------------------------------------
        tab:AddParagraph("قدرات إضافية / Player Boosts", "ميزات زيادة السرعة والتحرير")

        -- زيادة سرعة الحركة
        tab:AddToggle("سرعة فائقة / Speed Boost", false, function(enabled)
            if enabled then
                if not speedConn then
                    speedConn = RunService.Heartbeat:Connect(function()
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.WalkSpeed = 35
                        end
                    end)
                end
            elseif speedConn then
                speedConn:Disconnect()
                speedConn = nil
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                end
            end
        end)

        -- القفز اللانهائي
        tab:AddToggle("قفز لا نهائي / Infinite Jump", false, function(enabled)
            if enabled then
                if not jumpConn then
                    jumpConn = UserInputService.JumpRequest:Connect(function()
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end)
                end
            elseif jumpConn then
                jumpConn:Disconnect()
                jumpConn = nil
            end
        end)

        -- زر التحرير الفوري
        tab:AddButton("تحرير فوري للشخصية / Instant Break Free", function()
            local char = LocalPlayer.Character
            if not char then return end
            
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Anchored = false
                    v.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                elseif v:IsA("WeldConstraint") or v:IsA("RopeConstraint") or v:IsA("Weld") then
                    v:Destroy()
                end
            end
        end)

        ------------------------------------------------------------------------
        -- حلقة تحديث الشاشة
        ------------------------------------------------------------------------
        task.spawn(function()
            while tab.Page and tab.Page.Parent do
                pcall(updateStatus)
                task.wait(1.5)
            end
        end)
    end
}
