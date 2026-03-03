-- [[ Cryptic Hub - التحكم بالبلوكات (Hoverboard FE) V2 ]]
-- المطور: يامي (Yami) | التحديث: فلترة البلوكات الملتصقة، وقوف دقيق جداً، وأزرار تحكم محسنة

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
    local flySpeed = 40 -- سرعة الطيران

    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 })
        end)
    end

    -- [[ 1. تصميم أزرار الصعود والهبوط للجوال ]]
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrypticHoverUI_V2"
    ScreenGui.ResetOnSpawn = false
    local success, _ = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not success then ScreenGui.Parent = lp:WaitForChild("PlayerGui") end
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
        Instance.new("UIStroke", btn).Color = Color3.fromRGB(255, 255, 255)
        return btn
    end

    local BtnUp = createFlyButton("⬆️", -60)
    local BtnDown = createFlyButton("⬇️", 10)

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

    -- [[ 2. دوال التنظيف والفلترة الذكية ]]
    local function cleanupHover()
        isHovering = false
        ScreenGui.Enabled = false
        upActive, downActive = false, false

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

    -- دالة فحص البلوكة (تتجاهل المثبتة والملحومة بأشياء مثبتة)
    local function isFree(part)
        if not part or not part:IsA("BasePart") then return false end
        if part.Anchored then return false end
        -- فحص إذا كانت البلوكة ملحومة بجدار أو مبنى مثبت!
        if part.AssemblyRootPart and part.AssemblyRootPart.Anchored then return false end
        return true
    end

    -- [[ 3. زر تشغيل الخدعة ]]
    Tab:AddToggle("🛹 لوح التزلج الفيزيائي (Hoverboard)", function(state)
        if state then
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then 
                cleanupHover() 
                SendRobloxNotification("Cryptic Hub", "❌ شخصيتك غير مكتملة!")
                return 
            end

            -- تجاهل كل اللاعبين عشان الشعاع ما يضرب في لاعب ثاني
            local ignoreList = {char}
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then table.insert(ignoreList, p.Character) end
            end

            local params = RaycastParams.new()
            params.FilterDescendantsInstances = ignoreList
            params.FilterType = Enum.RaycastFilterType.Exclude

            local ray = workspace:Raycast(root.Position, Vector3.new(0, -15, 0), params)

            -- فحص البلوكة هل هي حرة تماماً؟
            if ray and isFree(ray.Instance) then
                hoverPart = ray.Instance
                isHovering = true
                ScreenGui.Enabled = true

                -- [[ الحساب الدقيق لوقوف اللاعب فوق البلوكة بالضبط ]]
                -- نحسب المسافة من منتصف شخصيتك إلى أسفل قدمك (تدعم R6 و R15)
                local legHeight = (hum.RigType == Enum.HumanoidRigType.R15) and (hum.HipHeight + (root.Size.Y / 2)) or 3
                -- نحسب نصف سُمك البلوكة
                local blockOffset = hoverPart.Size.Y / 2
                -- المسافة الكلية اللي تفصل بين الشخصية والبلوكة
                local totalOffset = legHeight + blockOffset

                -- تجميد اللاعب (عشان ما يطيح أو يتشقلب)
                hum.PlatformStand = true

                -- لحام البلوكة تحت قدمك بالملي
                hoverWeld = Instance.new("Weld")
                hoverWeld.Part0 = root
                hoverWeld.Part1 = hoverPart
                hoverWeld.C0 = CFrame.new(0, -totalOffset, 0)
                hoverWeld.Parent = root

                -- محركات الفيزياء (قوة جبارة تقدر تحمل لاعبين ثانيين معك!)
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = hoverPart

                bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.P = 9000
                bg.Parent = hoverPart

                SendRobloxNotification("Cryptic Hub", "✅ تم السحب بنجاح! طيران ممتع 🛸")

                -- [[ 4. حلقة التحكم والمحرك ]]
                connection = RunService.Heartbeat:Connect(function()
                    if not isHovering or not hoverPart or not hoverPart.Parent then 
                        cleanupHover() 
                        return 
                    end

                    -- أخذ اتجاه المشي من الدائرة/الجوستيك
                    local moveDir = hum.MoveDirection
                    
                    -- سرعة الصعود والهبوط من أزرار الشاشة
                    local yVel = 0
                    if upActive then yVel = flySpeed end
                    if downActive then yVel = -flySpeed end

                    -- دمج الاتجاهات وتطبيقها
                    local targetVel = (moveDir * flySpeed) + Vector3.new(0, yVel, 0)
                    bv.Velocity = targetVel

                    -- توجيه البلوكة عشان تبقى مسطحة وتلف مع لفة الكاميرا
                    local camLook = Camera.CFrame.LookVector
                    local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
                    if flatLook.Magnitude > 0.01 then
                        bg.CFrame = CFrame.new(hoverPart.Position, hoverPart.Position + flatLook.Unit)
                    end
                end)
            else
                SendRobloxNotification("Cryptic Hub", "⚠️ لم يتم العثور على بلوكة حرة تحتك!")
                cleanupHover()
            end
        else
            cleanupHover()
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف التحكم.")
        end
    end)
    
    Tab:AddLine()
end
