-- [[ Cryptic Hub - أداة الدوران / Spin Tool ]]
-- دوران فقط، بدون فلينج

return function(Tab, UI)
    local Players          = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService       = game:GetService("RunService")
    local StarterGui       = game:GetService("StarterGui")
    local lp               = Players.LocalPlayer

    local isActive  = false
    local spinSpeed = 5
    local sitConn   = nil
    local bav       = nil

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = "Cryptic Hub", Text = text, Duration = 3 })
        end)
    end

    local function GetRoot(char)
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    -- ==========================================
    -- BAV للدوران فقط (بدون فلينج)
    -- ==========================================
    local function ApplyBAV(char)
        local hrp = GetRoot(char)
        if not hrp then return end

        local old = hrp:FindFirstChild("CrypticSpinBAV")
        if old then old:Destroy() end

        bav = Instance.new("BodyAngularVelocity")
        bav.Name            = "CrypticSpinBAV"
        bav.AngularVelocity = Vector3.new(0, spinSpeed * 4, 0)
        bav.MaxTorque       = Vector3.new(0, math.huge, 0)
        bav.P               = math.huge
        bav.Parent          = hrp
    end

    local function RemoveBAV(char)
        if bav then pcall(function() bav:Destroy() end); bav = nil end
        if char then
            local hrp = GetRoot(char)
            if hrp then
                for _, v in pairs(hrp:GetChildren()) do
                    if v.ClassName == "BodyAngularVelocity" then v:Destroy() end
                end
            end
        end
    end

    local function UpdateSpeed()
        if bav and bav.Parent then
            pcall(function() bav.AngularVelocity = Vector3.new(0, spinSpeed * 4, 0) end)
        end
    end

    -- ==========================================
    -- مراقبة الجلوس
    -- ==========================================
    local function WatchSit(char)
        if sitConn then sitConn:Disconnect(); sitConn = nil end
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if not hum then return end
        sitConn = hum:GetPropertyChangedSignal("Sit"):Connect(function()
            if hum.Sit then
                if bav then pcall(function() bav.AngularVelocity = Vector3.new(0,0,0) end) end
            else
                UpdateSpeed()
            end
        end)
    end

    -- ==========================================
    -- صناعة الأداة
    -- ==========================================
    local function CreateSpinTool(char)
        local hum      = char:FindFirstChildWhichIsA("Humanoid")
        local backpack = lp:FindFirstChildWhichIsA("Backpack")
        if not hum or not backpack then return nil end

        local existing = backpack:FindFirstChild("Cryptic Spin") or char:FindFirstChild("Cryptic Spin")
        if existing then return existing end

        local tool = Instance.new("Tool")
        tool.Name           = "Cryptic Spin"
        tool.RequiresHandle = false
        tool.ToolTip        = "Cryptic Hub | Spin!"
        tool.Parent         = backpack

        tool.Equipped:Connect(function()
            local c    = lp.Character
            local hum2 = c and c:FindFirstChildWhichIsA("Humanoid")
            if hum2 then hum2.AutoRotate = false end
            if c and hum2 and not hum2.Sit then ApplyBAV(c) end
        end)

        tool.Unequipped:Connect(function()
            local c    = lp.Character
            local hum2 = c and c:FindFirstChildWhichIsA("Humanoid")
            if hum2 then hum2.AutoRotate = true end
            RemoveBAV(c)
        end)

        return tool
    end

    local function EnforceSlot(targetTool)
        local backpack = lp.Backpack
        if not backpack then return end
        local others = {}
        for _, t in pairs(backpack:GetChildren()) do
            if t.Name ~= "Cryptic Spin" then table.insert(others, t) end
        end
        if #others > 0 then
            local tmp = Instance.new("Folder")
            others[1].Parent = tmp; targetTool.Parent = tmp
            for i = 2, #others do others[i].Parent = tmp end
            task.wait(0.05)
            others[1].Parent = backpack; targetTool.Parent = backpack
            for i = 2, #others do others[i].Parent = backpack end
            tmp:Destroy()
        end
    end

    -- ==========================================
    -- واجهة الزر العائم
    -- ==========================================
    local function EnsureFloatingUI()
        if lp.PlayerGui:FindFirstChild("CrypticSpinUI") then return end
        local sg = Instance.new("ScreenGui")
        sg.Name = "CrypticSpinUI"; sg.ResetOnSpawn = false; sg.Parent = lp.PlayerGui

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,60,0,18); btn.Position = UDim2.new(0.5,-30,0,38)
        btn.BackgroundColor3 = Color3.fromRGB(80,0,200); btn.BackgroundTransparency = 0.55
        btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Text = "🔄 Spin"
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 10; btn.Active = true; btn.Parent = sg
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)

        local dragging, dragInput, dragStart, startPos, hasMoved = false,nil,nil,nil,false
        btn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging=true; hasMoved=false; dragStart=inp.Position; startPos=btn.Position
                inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then dragging=false end end)
            end
        end)
        btn.InputChanged:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then dragInput=inp end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if inp==dragInput and dragging then
                local d=inp.Position-dragStart
                if d.Magnitude>3 then hasMoved=true; btn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end
            end
        end)
        btn.MouseButton1Click:Connect(function()
            if hasMoved then return end
            local char=lp.Character; local hum=char and char:FindFirstChild("Humanoid"); if not hum then return end
            local inC=char:FindFirstChild("Cryptic Spin"); local inB=lp.Backpack:FindFirstChild("Cryptic Spin")
            if inC then hum:UnequipTools() elseif inB then hum:EquipTool(inB) end
        end)
        task.spawn(function()
            while sg.Parent do
                local char=lp.Character; local eq=char and char:FindFirstChild("Cryptic Spin")
                local hum=char and char:FindFirstChildWhichIsA("Humanoid"); local sit=hum and hum.Sit
                if eq and sit then btn.BackgroundColor3=Color3.fromRGB(180,120,0); btn.Text="⏸ Sitting"
                elseif eq then btn.BackgroundColor3=Color3.fromRGB(0,180,80); btn.Text="🟢 Spin ON"
                else btn.BackgroundColor3=Color3.fromRGB(80,0,200); btn.Text="🔄 Spin" end
                task.wait(0.2)
            end
        end)
    end

    local function Cleanup()
        if sitConn then sitConn:Disconnect(); sitConn=nil end
        local char=lp.Character; local hum=char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.AutoRotate=true end
        RemoveBAV(char)
        local ui=lp.PlayerGui:FindFirstChild("CrypticSpinUI"); if ui then ui:Destroy() end
        local inB=lp.Backpack:FindFirstChild("Cryptic Spin"); local inC=char and char:FindFirstChild("Cryptic Spin")
        if inB then inB:Destroy() end; if inC then inC:Destroy() end
    end

    lp.CharacterAdded:Connect(function(newChar)
        if isActive then
            task.wait(1.5); WatchSit(newChar)
            local t=CreateSpinTool(newChar); if t then EnforceSlot(t) end
        end
    end)

    local prevActive = false
    Tab:AddSpeedControl("أداة الدوران / Spin Tool", function(active, value)
        spinSpeed = tonumber(value) or 5
        isActive  = active
        UpdateSpeed()
        if active then
            local char=lp.Character; WatchSit(char)
            local t=CreateSpinTool(char); if t then EnforceSlot(t) end
            EnsureFloatingUI()
            -- إشعار فقط عند التشغيل (مو عند تغيير الرقم)
            if active ~= prevActive then
                Notify("🔄 دوران مفعّل! السرعة: "..spinSpeed)
            end
        else
            Cleanup()
            if active ~= prevActive then
                Notify("⛔ إيقاف الدوران")
            end
        end
        prevActive = active
    end, 5)
end
