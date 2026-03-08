-- [[ Cryptic Hub - حمل اللاعب المطور (Carry Player) ]]
-- المطور: يامي (Yami) | الميزات: أزرار تحكم بالارتفاع للجوال، تثبيت تحت الهدف، إشعارات مزدوجة

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local CoreGui = game:GetService("CoreGui")
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local liftHeight = -7
    local carryGui = nil
    
    -- دالة الإشعارات المزدوجة (عربي/إنجليزي)
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 10,
            })
        end)
    end

    -- دالة إنشاء أزرار التحكم بالارتفاع على الشاشة
    local function SetupHeightUI()
        if carryGui then carryGui:Destroy() end
        
        carryGui = Instance.new("ScreenGui")
        carryGui.Name = "CrypticCarryUI"
        carryGui.ResetOnSpawn = false
        pcall(function() carryGui.Parent = CoreGui end)
        if not carryGui.Parent then carryGui.Parent = lp:WaitForChild("PlayerGui") end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 60, 0, 130)
        frame.Position = UDim2.new(1, -80, 0.5, -65) -- على يمين الشاشة
        frame.BackgroundTransparency = 1
        frame.Parent = carryGui

        local upBtn = Instance.new("TextButton")
        upBtn.Size = UDim2.new(1, 0, 0.5, -5)
        upBtn.Position = UDim2.new(0, 0, 0, 0)
        upBtn.Text = "🔼"
        upBtn.TextScaled = true
        upBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        upBtn.BackgroundTransparency = 0.3
        upBtn.TextColor3 = Color3.new(1, 1, 1)
        upBtn.Parent = frame

        local downBtn = Instance.new("TextButton")
        downBtn.Size = UDim2.new(1, 0, 0.5, -5)
        downBtn.Position = UDim2.new(0, 0, 0.5, 5)
        downBtn.Text = "🔽"
        downBtn.TextScaled = true
        downBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        downBtn.BackgroundTransparency = 0.3
        downBtn.TextColor3 = Color3.new(1, 1, 1)
        downBtn.Parent = frame

        -- برمجة الأزرار للتحكم بالارتفاع
        upBtn.Activated:Connect(function() liftHeight = liftHeight + 1.5 end)
        downBtn.Activated:Connect(function() liftHeight = liftHeight - 1.5 end)
    end

    local function RemoveHeightUI()
        if carryGui then 
            carryGui:Destroy() 
            carryGui = nil 
        end
    end

    Tab:AddToggle("حمل اللاعب / Carry Player", function(active)
        isCarrying = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if active then
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isCarrying = false
                Notify(
                    "⚠️ حدد لاعباً أولاً من مربع البحث أعلى القائمة!",
                    "⚠️ Select a player first from the search box!"
                )
                return
            end
            
            -- إرجاع فحص التلامس كما طلبت
            local targetChar = _G.ArwaTarget.Character
            local myTorso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or root
            local targetTorso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("HumanoidRootPart")
            
            if myTorso and targetTorso then
                local success, canCollide = pcall(function()
                    return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, targetTorso.CollisionGroup)
                end)
                
                if success and not canCollide then
                    isCarrying = false
                    Notify(
                        "🚫 هذا الماب يلغي تلامس اللاعبين (No-Collide)!",
                        "🚫 Map disables player collision!"
                    )
                    return 
                end
            end
            
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end
            end
            
            liftHeight = -7
            SetupHeightUI() -- إظهار أزرار التحكم
            
            Notify(
                "🚀 جاري الرفع! (استخدم الأسهم على الشاشة للتحكم بالارتفاع)",
                "🚀 Lifting! (Use on-screen arrows to control height)"
            )
        else
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                
                if root then
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                    root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
                end

                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Massless = false 
                        part.CanCollide = true
                    end
                end
            end
            RemoveHeightUI() -- إخفاء الأزرار
            Notify(
                "❌ تم إيقاف الحمل وعدت لطبيعتك.",
                "❌ Carry stopped, returned to normal."
            )
        end
    end)

    -- [[ المحرك الفيزيائي (تثبيت تحت الهدف مباشرة) ]]
    runService.Heartbeat:Connect(function()
        if not isCarrying or not _G.ArwaTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local myHum = char and char:FindFirstChildOfClass("Humanoid")
        local targetChar = _G.ArwaTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot and myHum then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then
                        part.CanCollide = true
                    else
                        part.CanCollide = false
                    end
                    part.Massless = true
                end
            end

            local tPos = targetRoot.Position
            local tVel = targetRoot.Velocity

            -- نظام التقاط سريع إذا سقط الهدف
            if tVel.Y < -15 and liftHeight > -6 then
                liftHeight = -6 
            end

            -- التثبيت المباشر تحت الهدف بدون حركة جانبية
            root.CFrame = CFrame.new(tPos.X, tPos.Y + liftHeight, tPos.Z) * CFrame.Angles(math.rad(90), 0, 0)
            
            -- قوة دفع فيزيائية مستمرة للأعلى
            root.Velocity = Vector3.new(0, 15, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end
