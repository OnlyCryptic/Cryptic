-- [[ Cryptic Hub - التحكم بالبلوكات (Hoverboard FE+) V8 ]]
-- المطور: يامي (Yami) | التحديثات: دعم كامل للسيرفر (FE)، مركزية البلوكة، تحكم من اللاعب

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local isHovering = false
    local hoverPart = nil
    local hoverWeld = nil
    local crypticAttach, lv, ao = nil, nil, nil
    local connection = nil
    local deathConnection = nil
    
    local upActive, downActive = false, false
    local flySpeed = 50 

    local function SendRobloxNotification(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 }) end)
    end

    -- [[ تصميم واجهة الجوال ]]
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrypticHoverUI_V8"
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

        if hoverWeld then hoverWeld:Destroy() hoverWeld = nil end
        if crypticAttach then crypticAttach:Destroy() crypticAttach = nil end
        if lv then lv:Destroy() lv = nil end
        if ao then ao:Destroy() ao = nil end
        if connection then connection:Disconnect() connection = nil end
        
        -- إرجاع وزن البلوكة لحالته الطبيعية
        if hoverPart then
            pcall(function() hoverPart.Massless = false end)
            hoverPart = nil
        end
    end

    if deathConnection then deathConnection:Disconnect() end
    deathConnection = lp.CharacterAdded:Connect(function()
        cleanupHover()
    end)

    -- [[ دالة الفحص (تم تعديلها لتلتقط بلوكات أكثر) ]]
    local function isFree(part)
        if not part or not part:IsA("BasePart") then return false end
        -- ملاحظة: البلوكات المثبتة (Anchored) لا يمكن التحكم بها وجعل الآخرين يرونها بسبب قيود روبلوكس.
        -- يجب أن تكون البلوكة غير مثبتة لكي يعمل السكربت كـ FE (عام للسيرفر).
        if part.Anchored then return false end 
        
        local model = part:FindFirstAncestorOfClass("Model")
        if model then
            -- التأكد أن البلوكة ليست جزء من لاعب آخر
            if model:FindFirstChildOfClass("Humanoid") then return false end
        end
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

            if hum.SeatPart then
                hum.Sit = false
                task.wait(0.15)
            end

            local ignoreList = {char}
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then table.insert(ignoreList, p.Character) end
            end

            local params = RaycastParams.new()
            params.FilterDescendantsInstances = ignoreList
            params.FilterType = Enum.RaycastFilterType.Exclude

            local ray = workspace:Raycast(root.Position, Vector3.new(0, -30, 0), params)

            if ray and isFree(ray.Instance) then
                hoverPart = ray.Instance.AssemblyRootPart or ray.Instance

                isHovering = true
                ScreenGui.Enabled = true
                hum.PlatformStand = true

                -- 🔴 1. مسح المحركات القديمة إن وجدت
                for _, v in pairs(root:GetChildren()) do
                    if v.Name == "HoverWeldFE" or v.Name == "Cryptic_Attach" or v.Name == "Cryptic_LV" or v.Name == "Cryptic_AO" then 
                        v:Destroy() 
                    end
                end

                -- 🔴 2. تمركز البلوكة تحتك بالضبط
                local legHeight = (hum.RigType == Enum.HumanoidRigType.R15) and (hum.HipHeight + (root.Size.Y / 2)) or 3
                local partOffset = (hoverPart.Size.Y / 2)
                
                -- سحب البلوكة وجعلها في المنتصف تحت قدميك
                hoverPart.CFrame = root.CFrame * CFrame.new(0, -(legHeight + partOffset), 0)
                
                -- إزالة وزن البلوكة لكي لا تسحبك للأسفل
                hoverPart.Massless = true
                hoverPart.CanCollide = true -- تفعيل التصادم لكي يركب معك الآخرون

                -- 🔴 3. استخدام WeldConstraint لدمج البلوكة باللاعب دون إفساد الفيزياء
                hoverWeld = Instance.new("WeldConstraint")
                hoverWeld.Name = "HoverWeldFE"
                hoverWeld.Part0 = root
                hoverWeld.Part1 = hoverPart
                hoverWeld.Parent = root

                -- 🔴 4. وضع محركات الطيران على "اللاعب" وليس البلوكة (هذا هو سر الـ FE)
                crypticAttach = Instance.new("Attachment")
                crypticAttach.Name = "Cryptic_Attach"
                crypticAttach.Parent = root

                lv = Instance.new("LinearVelocity")
                lv.Name = "Cryptic_LV"
                lv.Attachment0 = crypticAttach
                lv.ForceLimitMode = Enum.ForceLimitMode.PerAxis
                lv.MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge)
                lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                lv.Parent = root

                ao = Instance.new("AlignOrientation")
                ao.Name = "Cryptic_AO"
                ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
                ao.Attachment0 = crypticAttach
                ao.RigidityEnabled = true 
                ao.MaxTorque = math.huge
                ao.MaxAngularVelocity = math.huge
                ao.Parent = root

                SendRobloxNotification("Cryptic Hub", "✅ تم التفعيل! السيرفر يرى البلوكة الآن 🌐")

                connection = RunService.Heartbeat:Connect(function()
                    if not isHovering or not root or not root.Parent then 
                        cleanupHover() 
                        return 
                    end

                    local moveDir = hum.MoveDirection
                    local yVel = 0
                    if upActive then yVel = flySpeed end
                    if downActive then yVel = -flySpeed end

                    -- تحريك اللاعب (والبلوكة ستتبعه تلقائياً)
                    lv.VectorVelocity = (moveDir * flySpeed) + Vector3.new(0, yVel, 0)

                    local currentCamLook = Camera.CFrame.LookVector
                    local currentFlatLook = Vector3.new(currentCamLook.X, 0, currentCamLook.Z)
                    if currentFlatLook.Magnitude > 0.01 then
                        ao.CFrame = CFrame.new(root.Position, root.Position + currentFlatLook.Unit)
                    end
                end)
            else
                SendRobloxNotification("Cryptic Hub", "⚠️ يجب أن تقف على بلوكة غير مثبتة (Unanchored)!")
                cleanupHover()
            end
        else
            cleanupHover()
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف التحكم.")
        end
    end)
end
