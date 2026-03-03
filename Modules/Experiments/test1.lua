-- [[ Cryptic Hub - التحكم بالبلوكات (Hoverboard FE) ]]
-- المطور: يامي (Yami) | التحديث: طيران على البلوكات غير المثبتة مع أزرار للجوال

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local isHovering = false
    local hoverPart = nil
    local hoverWeld = nil
    local bv, bg = nil, nil
    local connection = nil
    
    local upActive, downActive = false, false
    local flySpeed = 40 -- سرعة الطيران (تقدر تعدلها)

    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 })
        end)
    end

    -- [[ 1. تصميم أزرار الصعود والهبوط للجوال ]]
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrypticHoverUI"
    ScreenGui.ResetOnSpawn = false
    local success, _ = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not success then ScreenGui.Parent = lp:WaitForChild("PlayerGui") end
    ScreenGui.Enabled = false

    local function createFlyButton(text, yPos)
        local btn = Instance.new("TextButton", ScreenGui)
        btn.Size = UDim2.new(0, 50, 0, 50)
        btn.Position = UDim2.new(1, -80, 0.5, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.BackgroundTransparency = 0.5
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(0, 255, 150)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 24
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        Instance.new("UIStroke", btn).Color = Color3.fromRGB(255, 255, 255)
        
        return btn
    end

    local BtnUp = createFlyButton("⬆️", -40)
    local BtnDown = createFlyButton("⬇️", 20)

    -- نظام اللمس للأزرار
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

    -- [[ 2. دالة التنظيف (لإرجاع كل شيء لطبيعته) ]]
    local function cleanupHover()
        isHovering = false
        ScreenGui.Enabled = false
        upActive = false
        downActive = false

        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end

        if hoverWeld then hoverWeld:Destroy() hoverWeld = nil end
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        if connection then connection:Disconnect() connection = nil end
        hoverPart = nil
    end

    -- [[ 3. زر تشغيل الخدعة ]]
    Tab:AddToggle("🛹 التحكم ببلوكة (Hoverboard)", function(state)
        if state then
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then 
                cleanupHover() 
                SendRobloxNotification("Cryptic Hub", "❌ شخصيتك غير مكتملة!")
                return 
            end

            -- إطلاق شعاع (Raycast) للأسفل للبحث عن بلوكة غير مثبتة
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char}
            params.FilterType = Enum.RaycastFilterType.Exclude

            local ray = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), params)

            if ray and ray.Instance and not ray.Instance.Anchored then
                hoverPart = ray.Instance
                isHovering = true
                ScreenGui.Enabled = true

                -- نقل البلوكة تحت رجل اللاعب فوراً
                hoverPart.CFrame = root.CFrame * CFrame.new(0, -3, 0)

                -- تجميد اللاعب (عشان ما يطيح)
                hum.PlatformStand = true

                -- لحام البلوكة باللاعب
                hoverWeld = Instance.new("Weld")
                hoverWeld.Part0 = root
                hoverWeld.Part1 = hoverPart
                hoverWeld.C0 = CFrame.new(0, -3, 0) -- المسافة تحت الرجل
                hoverWeld.Parent = root

                -- محركات الفيزياء للبلوكة
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = hoverPart

                bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.P = 9000
                bg.Parent = hoverPart

                SendRobloxNotification("Cryptic Hub", "✅ تم سحب البلوكة! يمكنك الطيران الآن.")

                -- [[ 4. حلقة التحكم (المحرك) ]]
                connection = RunService.Heartbeat:Connect(function()
                    if not isHovering or not hoverPart or not hoverPart.Parent then 
                        cleanupHover() 
                        return 
                    end

                    -- أخذ اتجاه دائرة التحكم (الجوستيك) العادية
                    local moveDir = hum.MoveDirection
                    
                    -- حساب سرعة الصعود والهبوط
                    local yVel = 0
                    if upActive then yVel = flySpeed end
                    if downActive then yVel = -flySpeed end

                    -- دمج الاتجاهات وتطبيقها على البلوكة
                    local targetVel = (moveDir * flySpeed) + Vector3.new(0, yVel, 0)
                    bv.Velocity = targetVel

                    -- توجيه البلوكة لتلائم اتجاه الكاميرا
                    bg.CFrame = CFrame.new(hoverPart.Position, hoverPart.Position + Camera.CFrame.LookVector)
                end)
            else
                SendRobloxNotification("Cryptic Hub", "⚠️ لم يتم العثور على بلوكة غير مثبتة تحتك!")
                cleanupHover()
            end
        else
            cleanupHover()
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف التحكم.")
        end
    end)
    
    Tab:AddLine()
end
