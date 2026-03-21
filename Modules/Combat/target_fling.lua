-- [[ Cryptic Hub - تطيير الهدف المطور (Classic Spin Target V7) ]]
-- المطور: يامي | الميزات: دوران كلاسيكي قوي، تتبع مغناطيسي للهدف، كاميرا ثابتة، وعودة آمنة

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer
    
    local isFlinging = false
    local originalCFrame = nil
    local bav, bp = nil, nil
    local steppedConn = nil

    -- دالة إشعارات روبلوكس (مزدوجة اللغة)
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 5, 
            })
        end)
    end

    local function CleanMovers()
        if bav then bav:Destroy() bav = nil end
        if bp then bp:Destroy() bp = nil end
        if steppedConn then steppedConn:Disconnect() steppedConn = nil end
    end

    -- [[ زر التفعيل ]]
    Tab:AddToggle("تطيير الهدف / Fling Target", function(active)
        isFlinging = active
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))

        if active then
            -- 1. فحص وجود الهدف
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isFlinging = false
                Notify(
                    "⚠️ حدد لاعباً أولاً من مربع البحث أعلى القائمة!",
                    "Select a player first from the search box!"
                )
                return
            end

            -- 2. فحص نظام التصادم (No-Collide Check)
            local targetChar = _G.ArwaTarget.Character
            local targetTorso = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("HumanoidRootPart")
            
            if torso and targetTorso then
                local success, canCollide = pcall(function()
                    return PhysicsService:CollisionGroupsAreCollidable(torso.CollisionGroup, targetTorso.CollisionGroup)
                end)
                
                if success and not canCollide then
                    isFlinging = false
                    Notify(
                        "🚫 هذا الماب يلغي تلامس اللاعبين (No-Collide)، الخدعة لن تعمل هنا!",
                        "This map disables player collision, trick won't work here!"
                    )
                    return 
                end
            end

            if not root or not hum or not torso then return end

            -- 3. حفظ المكان للعودة الآمنة
            originalCFrame = root.CFrame

            -- 4. تجهيز الشخصية للطيران والدوران
            CleanMovers()
            hum.PlatformStand = true
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

            -- أداة الدوران الكلاسيكية (في الجذع لضمان عدم تخريب الكاميرا)
            bav = Instance.new("BodyAngularVelocity")
            bav.Name = "CrypticTargetFlingBAV"
            bav.AngularVelocity = Vector3.new(0, 25000, 0) -- سرعة دوران مجنونة أفقية
            bav.MaxTorque = Vector3.new(0, math.huge, 0)
            bav.P = math.huge
            bav.Parent = torso

            -- أداة التتبع المغناطيسي
            bp = Instance.new("BodyPosition")
            bp.Name = "CrypticTargetFlingBP"
            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bp.P = 15000
            bp.D = 100
            bp.Parent = root

            -- تخفيف وزن الشخصية
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Massless = true
                    part.CanCollide = false
                end
            end

            Notify(
                "🌪️ جاري الدوران وتطيير: " .. _G.ArwaTarget.DisplayName,
                "Spinning and flinging: " .. _G.ArwaTarget.DisplayName
            )

            -- 5. المحرك: تتبع الهدف باستمرار والحفاظ على ثبات الكاميرا
            steppedConn = RunService.Stepped:Connect(function()
                if root and hum.Health > 0 and _G.ArwaTarget and _G.ArwaTarget.Character then
                    local targetRoot = _G.ArwaTarget.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        -- تصفير دوران الروت لتبقى واقفاً والكاميرا ثابتة أثناء الدوران
                        root.RotVelocity = Vector3.new(0, 0, 0)
                        
                        -- تحديث موقع السحب ليكون مكان الهدف
                        bp.Position = targetRoot.Position
                        
                        -- تفعيل التصادم للروت فقط لضرب الهدف بقوة
                        root.CanCollide = true
                        root.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 1)
                    end
                end
            end)

        else
            -- [[ الإيقاف والعودة الآمنة لمكانك ]]
            CleanMovers()
            
            if char and root and hum then
                hum.PlatformStand = false 
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                
                -- إيقاف الحركة
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
                if torso then torso.RotVelocity = Vector3.new(0, 0, 0) end
                
                -- العودة للمكان الأصلي بسلام
                if originalCFrame then
                    root.CFrame = originalCFrame
                    originalCFrame = nil
                end

                -- إرجاع الأوزان والخصائص الطبيعية
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Massless = false 
                        part.CustomPhysicalProperties = nil
                        if part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
            end

            Notify(
                "❌ توقف التطيير وعدت لمكانك بأمان.",
                "Fling stopped, returned safely."
            )
        end
    end)
end
