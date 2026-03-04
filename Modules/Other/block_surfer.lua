-- [[ Cryptic Hub - التحكم بالبلوكات (Hoverboard FE) V4 ]]
-- المطور: يامي (Yami) | التحديث: وقوف مستقيم 100% من أول ثانية بدون أي ميلان

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
    ScreenGui.Name = "CrypticHoverUI_V4"
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
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
            end
        end

        if hoverWeld then hoverWeld:Destroy() hoverWeld = nil end
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        if connection then connection:Disconnect() connection = nil end
        hoverPart = nil
    end

    local function isFree(part)
        if not part or not part:IsA("BasePart") then return false end
        if part.Anchored then return false end
        if part.AssemblyRootPart and part.AssemblyRootPart.Anchored then return false end
        return true
    end

    -- [[ 3. زر تشغيل الخدعة ]]
    Tab:AddToggle("ركوب البلوكات / Block Surfer", function(state)
        if state then
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then 
                cleanupHover() 
                SendRobloxNotification("Cryptic Hub", "❌ شخصيتك غير مكتملة!")
                return 
            end

            local ignoreList = {char}
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then table.insert(ignoreList, p.Character) end
            end

            local params = RaycastParams.new()
            params.FilterDescendantsInstances = ignoreList
            params.FilterType = Enum.RaycastFilterType.Exclude

            local ray = workspace:Raycast(root.Position, Vector3.new(0, -15, 0), params)

            if ray and isFree(ray.Instance) then
                hoverPart = ray.Instance
                isHovering = true
                ScreenGui.Enabled = true

                -- إيقاف أي حركة أو ميلان سابق فوراً
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)

                -- تسطيح البلوكة
                local size = hoverPart.Size
                local sx, sy, sz = size.X, size.Y, size.Z
                local minAxis = math.min(sx, sy, sz)
                
                local partRotation = CFrame.Angles(0, 0, 0)
                local blockThickness = sy

                if minAxis == sx then
                    partRotation = CFrame.Angles(0, 0, math.rad(90))
                    blockThickness = sx
                elseif minAxis == sz then
                    partRotation = CFrame.Angles(math.rad(90), 0, 0)
                    blockThickness = sz
                end

                local legHeight = (hum.RigType == Enum.HumanoidRigType.R15) and (hum.HipHeight + (root.Size.Y / 2)) or 3
                local totalOffset = legHeight + (blockThickness / 2)

                hum.PlatformStand = true

                -- إجبار اللاعب على الوقوف بشكل مستقيم 100% قبل اللحام
                local camLook = Camera.CFrame.LookVector
                local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
                if flatLook.Magnitude > 0.01 then
                    root.CFrame = CFrame.new(root.Position, root.Position + flatLook.Unit)
                end

                -- لحام البلوكة
                hoverWeld = Instance.new("Weld")
                hoverWeld.Part0 = root
                hoverWeld.Part1 = hoverPart
                hoverWeld.C0 = CFrame.new(0, -totalOffset, 0)
                hoverWeld.C1 = partRotation
                hoverWeld.Parent = root

                -- محركات الفيزياء
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = root

                bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.P = 25000 -- قوة جبارة للتوازن الفوري والصلب
                -- ضبط التوازن المبدئي فوراً عشان ما يميل ولا ملي
                if flatLook.Magnitude > 0.01 then
                    bg.CFrame = CFrame.new(root.Position, root.Position + flatLook.Unit)
                else
                    bg.CFrame = root.CFrame
                end
                bg.Parent = root

                SendRobloxNotification("Cryptic Hub", "✅ وقوف مستقيم! طيران ممتع 🛸")

                -- [[ 4. حلقة التحكم ]]
                connection = RunService.Heartbeat:Connect(function()
                    if not isHovering or not hoverPart or not hoverPart.Parent then 
                        cleanupHover() 
                        return 
                    end

                    local moveDir = hum.MoveDirection
                    local yVel = 0
                    if upActive then yVel = flySpeed end
                    if downActive then yVel = -flySpeed end

                    bv.Velocity = (moveDir * flySpeed) + Vector3.new(0, yVel, 0)

                    local currentCamLook = Camera.CFrame.LookVector
                    local currentFlatLook = Vector3.new(currentCamLook.X, 0, currentCamLook.Z)
                    if currentFlatLook.Magnitude > 0.01 then
                        bg.CFrame = CFrame.new(root.Position, root.Position + currentFlatLook.Unit)
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
