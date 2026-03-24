-- [[ Cryptic Hub - WalkFling Final Optimized Version ]]

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    -- 📢 دالة الإشعارات
    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 4
            })
        end)
    end

    -- 🔍 فحص تصادم الماب (Collision Check)
    local function CheckCollisionAllowed()
        local isAllowed = true
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local myTorso = lp.Character and (lp.Character:FindFirstChild("UpperTorso") or lp.Character:FindFirstChild("Torso"))
                local tgtTorso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
                if myTorso and tgtTorso then
                    local ok, can = pcall(function()
                        return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, tgtTorso.CollisionGroup)
                    end)
                    if ok and not can then isAllowed = false break end
                end
            end
        end
        return isAllowed
    end

    -- 🛠️ دالة إنشاء الزر (AddAutoOffToggle) مع فحص مسبق
    local function AddAutoOffToggle(label, callback)
        Tab.Order = Tab.Order or 0
        Tab.Order = Tab.Order + 1
        local ParentPage = Tab.Page or Tab.Container or Tab
        
        local R = Instance.new("Frame", ParentPage)
        R.LayoutOrder = Tab.Order
        R.Size = UDim2.new(0.98, 0, 0, 45)
        R.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Instance.new("UICorner", R)
        
        local B = Instance.new("TextButton", R)
        B.Size = UDim2.new(0, 45, 0, 22)
        B.Position = UDim2.new(1, -55, 0.5, -11)
        B.Text = ""
        B.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0)
        
        local Lbl = Instance.new("TextLabel", R)
        Lbl.Text = label
        Lbl.Size = UDim2.new(1, -65, 1, 0)
        Lbl.Position = UDim2.new(0, 5, 0, 0)
        Lbl.TextColor3 = Color3.new(1, 1, 1)
        Lbl.BackgroundTransparency = 1
        Lbl.TextXAlignment = Enum.TextXAlignment.Right
        Lbl.Font = Enum.Font.GothamSemibold
        Lbl.TextSize = 11
        
        local isActive = false
        local configKey = (Tab.TabName or "Tab") .. "_" .. label
        
        local function setState(state, isManual)
            -- إذا كان يحاول التفعيل، نفحص الماب أولاً
            if state == true and not CheckCollisionAllowed() then
                Notify("🚫 الماب لا يدعم التلامس", "🚫 Map doesn't support collision")
                return -- نخرج فوراً دون تغيير حالة الزر
            end

            isActive = state
            B.BackgroundColor3 = isActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 60)
            if UI and UI.ConfigData then UI.ConfigData[configKey] = isActive end
            pcall(callback, isActive, isManual)
        end
        
        B.MouseButton1Click:Connect(function() setState(not isActive, true) end)

        local function setupDeathEvent(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then
                hum.Died:Connect(function()
                    if isActive then
                        setState(false, false)
                        Notify("⚠️ تم إيقاف الميزة بسبب موتك", "⚠️ Feature disabled due to death")
                    end
                end)
            end
        end

        if lp.Character then task.spawn(function() setupDeathEvent(lp.Character) end) end
        lp.CharacterAdded:Connect(setupDeathEvent)

        return { SetState = function(self, state) setState(state, false) end }
    end

    -- 🚀 المتغيرات الأساسية للسكربت
    local walkflinging = false
    local noclipConn = nil
    local antiflingConn = nil
    local flingThread = nil

    -- 🛑 إيقاف كل شيء (Clean up)
    local function StopAll()
        walkflinging = false
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if antiflingConn then antiflingConn:Disconnect() antiflingConn = nil end
        if flingThread then task.cancel(flingThread) flingThread = nil end
    end

    -- 🟢 إنشاء الزر والتحكم في الوظائف
    local walkFlingToggle
    walkFlingToggle = AddAutoOffToggle("تطير ناس بلمسهم/ WalkFling", function(active, isManual)
        if active then
            walkflinging = true
            Notify("✅ تم التفعيل!", "✅ Walk into players to fling them")

            -- [1] النوكليب الكامل (Noclip)
            noclipConn = RunService.Stepped:Connect(function()
                if not walkflinging then return end
                if lp.Character then
                    for _, p in pairs(lp.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)

            -- [2] الأنتي فلينج القوي (Anti-Fling)
            antiflingConn = RunService.Stepped:Connect(function()
                if not walkflinging then return end
                for _, pl in pairs(Players:GetPlayers()) do
                    if pl ~= lp and pl.Character then
                        for _, part in pairs(pl.Character:GetDescendants()) do
                            if part:IsA("BasePart") then 
                                part.CanCollide = false 
                                part.Velocity = Vector3.new(0, 0, 0)
                                part.RotVelocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end
                end
            end)

            -- [3] لوب التطير (Fling Loop) القوي
            flingThread = task.spawn(function()
                local movel = 0.1
                while walkflinging do
                    RunService.Heartbeat:Wait()
                    local char = lp.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if char and char.Parent and root and root.Parent then
                        local vel = root.AssemblyLinearVelocity
                        root.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)
                        
                        RunService.RenderStepped:Wait()
                        if root.Parent then root.AssemblyLinearVelocity = vel end
                        
                        RunService.Stepped:Wait()
                        if root.Parent then 
                            root.AssemblyLinearVelocity = vel + Vector3.new(0, movel, 0)
                            movel = movel * -1
                        end
                    end
                end
            end)
        else
            -- عند الإغلاق
            StopAll()
            
            -- ريستارت فقط إذا كان الإغلاق يدوياً والشخصية لا تزال حية
            if isManual then
                local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    hum.Health = 0
                    Notify("🔄 جاري إعادة الشخصية...", "🔄 Resetting character...")
                end
            end
        end
    end)
end
