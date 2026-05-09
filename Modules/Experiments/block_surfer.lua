-- [[ Cryptic Hub - التحكم بالبلوكات (Hoverboard FE Ultimate) V9 ]]
-- المطور: يامي (Yami) | التحديثات: إصلاح ملكية الشبكة، البلوكة تتحرك للجميع، استقرار تام بدون دمج

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local isHovering = false
    local hoverPart = nil
    local bv, bg = nil, nil
    local connection = nil
    local deathConnection = nil
    
    local upActive, downActive = false, false
    local flySpeed = 50 

    local function SendRobloxNotification(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 }) end)
    end

    -- [[ تصميم واجهة الجوال ]]
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrypticHoverUI_V9"
    ScreenGui.ResetOnSpawn = false
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then ScreenGui.Parent = lp:WaitForChild("PlayerGui") end
    ScreenGui.Enabled = false

    local function createFlyButton(text, yPos)
        local btn = Instance.new("TextButton", ScreenGui)
        btn.Size = UDim2.new(0, 55, 0, 55)
        btn.Position = UDim2.new(1, -85, 0.5, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.BackgroundTransparency = 0.5
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(0, 255, 150)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 24
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        return btn
    end

    local BtnUp = createFlyButton("⬆️", -60)
    local BtnDown = createFlyButton("⬇️", 10)

    local function setupTouch(btn, isUp)
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if isUp then upActive = true else downActive = true end
                btn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if isUp then upActive = false else downActive = false end
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            end
        end)
    end
    setupTouch(BtnUp, true)
    setupTouch(BtnDown, false)

    -- [[ دوال التنظيف ]]
    local function cleanupHover()
        isHovering = false
        ScreenGui.Enabled = false
        upActive, downActive = false, false

        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
            end
        end

        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        if connection then connection:Disconnect() connection = nil end
        
        if hoverPart then
            pcall(function() hoverPart.Massless = false end)
            hoverPart = nil
        end
    end

    if deathConnection then deathConnection:Disconnect() end
    deathConnection = lp.CharacterAdded:Connect(function()
        cleanupHover()
    end)

    -- [[ دالة الفحص الذكية ]]
    local function isFree(part)
        if not part or not part:IsA("BasePart") then return false end
        -- البلوكة المثبتة (Anchored) مستحيل السيرفر يقبل حركتها، لازم نستثنيها.
        if part.Anchored then return false end 
        
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChildOfClass("Humanoid") then return false end
        return true
    end

    -- [[ تشغيل السكربت ]]
    Tab:AddToggle("ركوب البلوكات (FE) / Object Surfer", function(state)
        if state then
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if not root or not hum then 
                cleanupHover() 
                SendRobloxNotification("Cryptic Hub", "❌ شخصيتك غير مكتملة!")
                return 
            end

            if hum.SeatPart then hum.Sit = false task.wait(0.15) end

            local ignoreList = {char}
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then table.insert(ignoreList, p.Character) end
            end

            local params = RaycastParams.new()
            params.FilterDescendantsInstances = ignoreList
            params.FilterType = Enum.RaycastFilterType.Exclude

            local ray = workspace:Raycast(root.Position, Vector3.new(0, -30, 0), params)

            if ray then
                if not isFree(ray.Instance) then
                    SendRobloxNotification("Cryptic Hub", "⚠️ هذه البلوكة مثبتة (Anchored) ولا يمكن التحكم بها عالمياً!")
                    cleanupHover()
                    return
                end

                hoverPart = ray.Instance.AssemblyRootPart or ray.Instance

                isHovering = true
                ScreenGui.Enabled = true
                hum.PlatformStand = true -- إيقاف حركة اللاعب الطبيعية

                -- تنظيف أي محركات قديمة
                for _, v in pairs(hoverPart:GetChildren()) do
                    if v.Name == "Cryptic_BV" or v.Name == "Cryptic_BG" then v:Destroy() end
                end

                hoverPart.Massless = true
                hoverPart.CanCollide = true

                -- 🔴 1. وضع محركات كلاسيكية قوية (BodyMovers) داخل البلوكة، السيرفر يعشقها وتنسخ بسرعة!
                bv = Instance.new("BodyVelocity")
                bv.Name = "Cryptic_BV"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = hoverPart

                bg = Instance.new("BodyGyro")
                bg.Name = "Cryptic_BG"
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.P = 9000
                bg.D = 500
                bg.CFrame = hoverPart.CFrame
                bg.Parent = hoverPart

                -- حساب الارتفاع لتركيب اللاعب فوق منتصف البلوكة
                local partOffset = (hoverPart.Size.Y / 2)
                local legHeight = (hum.RigType == Enum.HumanoidRigType.R15) and (hum.HipHeight + (root.Size.Y / 2)) or 3
                local totalOffset = partOffset + legHeight + 0.5 

                SendRobloxNotification("Cryptic Hub", "✅ تم الاستحواذ على البلوكة! (الآن يراها الجميع) 🌐")

                -- 🔴 2. التحديث المستمر
                connection = RunService.Heartbeat:Connect(function()
                    if not isHovering or not hoverPart or not hoverPart.Parent or not root then 
                        cleanupHover() 
                        return 
                    end

                    -- سر الاستحواذ: نقل شخصيتك فوق البلوكة كل فريم عشان السيرفر يعطيك ملكيتها!
                    -- ممنوع نغير CFrame البلوكة، نغير CFrame اللاعب فقط.
                    root.CFrame = hoverPart.CFrame * CFrame.new(0, totalOffset, 0)
                    root.Velocity = hoverPart.Velocity -- تزامن السرعة لمنع الاهتزاز

                    -- توجيه البلوكة
                    local moveDir = hum.MoveDirection
                    local yVel = 0
                    if upActive then yVel = flySpeed end
                    if downActive then yVel = -flySpeed end

                    bv.Velocity = (moveDir * flySpeed) + Vector3.new(0, yVel, 0)

                    local currentCamLook = Camera.CFrame.LookVector
                    local currentFlatLook = Vector3.new(currentCamLook.X, 0, currentCamLook.Z)
                    if currentFlatLook.Magnitude > 0.01 then
                        bg.CFrame = CFrame.new(hoverPart.Position, hoverPart.Position + currentFlatLook.Unit)
                    end
                end)
            else
                SendRobloxNotification("Cryptic Hub", "⚠️ لم يتم العثور على بلوكة تحتك!")
                cleanupHover()
            end
        else
            cleanupHover()
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف التحكم.")
        end
    end)
end
