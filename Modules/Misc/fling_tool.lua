-- [[ Cryptic Hub - أداة الفلينج / Fling Tool ]]
-- فلينج فقط: كثافة عالية + نبضات BAV = كل من يلمسك يطير

return function(Tab, UI)
    local Players          = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui       = game:GetService("StarterGui")
    local lp               = Players.LocalPlayer

    local isActive = false
    local bav      = nil

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = "Cryptic Hub", Text = text, Duration = 3 })
        end)
    end

    local function GetRoot(char)
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    -- ==========================================
    -- تفعيل فيزياء الفلينج
    -- ==========================================
    local function ApplyFling(char)
        local hrp = GetRoot(char)
        if not hrp then return end

        -- كثافة عالية = من يلمسك يطير
        for _, child in pairs(char:GetDescendants()) do
            if child:IsA("BasePart") then
                pcall(function()
                    child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
                end)
            end
        end

        -- صفّر السرعة الأولية
        for _, child in pairs(char:GetDescendants()) do
            if child:IsA("BasePart") then
                pcall(function() child.AssemblyLinearVelocity = Vector3.zero end)
            end
        end

        -- مسح القديم
        local old = hrp:FindFirstChild("CrypticFlingBAV")
        if old then old:Destroy() end

        bav = Instance.new("BodyAngularVelocity")
        bav.Name            = "CrypticFlingBAV"
        bav.AngularVelocity = Vector3.new(0, 99999, 0)
        bav.MaxTorque       = Vector3.new(0, math.huge, 0)
        bav.P               = math.huge
        bav.Parent          = hrp

        -- نبضات الفلينج: 99999 ↔ 0 — كل اصطدام يطير اللاعب
        task.spawn(function()
            while bav and bav.Parent and isActive do
                pcall(function() bav.AngularVelocity = Vector3.new(0, 99999, 0) end)
                task.wait(0.2)
                pcall(function() bav.AngularVelocity = Vector3.new(0, 0, 0) end)
                task.wait(0.1)
            end
        end)
    end

    local function RemoveFling(char)
        if bav then pcall(function() bav:Destroy() end); bav = nil end
        if char then
            local hrp = GetRoot(char)
            if hrp then
                for _, v in pairs(hrp:GetChildren()) do
                    if v.ClassName == "BodyAngularVelocity" and v.Name == "CrypticFlingBAV" then v:Destroy() end
                end
            end
            for _, child in pairs(char:GetDescendants()) do
                if child:IsA("BasePart") then
                    pcall(function()
                        child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                    end)
                end
            end
        end
    end

    -- ==========================================
    -- صناعة الأداة
    -- ==========================================
    local function CreateFlingTool(char)
        local hum      = char:FindFirstChildWhichIsA("Humanoid")
        local backpack = lp:FindFirstChildWhichIsA("Backpack")
        if not hum or not backpack then return nil end

        local existing = backpack:FindFirstChild("Cryptic Fling") or char:FindFirstChild("Cryptic Fling")
        if existing then return existing end

        local tool = Instance.new("Tool")
        tool.Name           = "Cryptic Fling"
        tool.RequiresHandle = false
        tool.ToolTip        = "Cryptic Hub | Fling anyone who touches you!"
        tool.Parent         = backpack

        tool.Equipped:Connect(function()
            local c = lp.Character
            if c then ApplyFling(c) end
        end)

        tool.Unequipped:Connect(function()
            RemoveFling(lp.Character)
        end)

        return tool
    end

    local function EnforceSlot(targetTool)
        local backpack = lp.Backpack
        if not backpack then return end
        local others = {}
        for _, t in pairs(backpack:GetChildren()) do
            if t.Name ~= "Cryptic Fling" then table.insert(others, t) end
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
        if lp.PlayerGui:FindFirstChild("CrypticFlingUI") then return end
        local sg = Instance.new("ScreenGui")
        sg.Name = "CrypticFlingUI"; sg.ResetOnSpawn = false; sg.Parent = lp.PlayerGui

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,65,0,18); btn.Position = UDim2.new(0.5,-32,0,60)
        btn.BackgroundColor3 = Color3.fromRGB(200,50,0); btn.BackgroundTransparency = 0.55
        btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Text = "💥 Fling"
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
            local inC=char:FindFirstChild("Cryptic Fling"); local inB=lp.Backpack:FindFirstChild("Cryptic Fling")
            if inC then hum:UnequipTools() elseif inB then hum:EquipTool(inB) end
        end)
        task.spawn(function()
            while sg.Parent do
                local char=lp.Character; local eq=char and char:FindFirstChild("Cryptic Fling")
                if eq then btn.BackgroundColor3=Color3.fromRGB(0,180,80); btn.Text="🟢 Fling ON"
                else btn.BackgroundColor3=Color3.fromRGB(200,50,0); btn.Text="💥 Fling" end
                task.wait(0.2)
            end
        end)
    end

    local function Cleanup()
        local char=lp.Character
        RemoveFling(char)
        local ui=lp.PlayerGui:FindFirstChild("CrypticFlingUI"); if ui then ui:Destroy() end
        local inB=lp.Backpack:FindFirstChild("Cryptic Fling"); local inC=char and char:FindFirstChild("Cryptic Fling")
        if inB then inB:Destroy() end; if inC then inC:Destroy() end
    end

    lp.CharacterAdded:Connect(function(newChar)
        if isActive then
            task.wait(1.5)
            local t=CreateFlingTool(newChar); if t then EnforceSlot(t) end
        end
    end)

    -- ==========================================
    -- Toggle بسيط (بدون SpeedControl)
    -- ==========================================
    Tab:AddToggle("أداة الفلينج / Fling Tool", function(active)
        isActive = active
        if active then
            local char=lp.Character
            local t=CreateFlingTool(char); if t then EnforceSlot(t) end
            EnsureFloatingUI()
            Notify("💥 فلينج مفعّل! جهّز الأداة\n💥 Fling ON! Equip the tool")
        else
            Cleanup()
            Notify("⛔ إيقاف الفلينج\n⛔ Fling OFF!")
        end
    end)
end
