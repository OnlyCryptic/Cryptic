-- [[ Cryptic Hub - أداة الفلينج / Fling Tool ]]

return function(Tab, UI)
    local Players          = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui       = game:GetService("StarterGui")
    local RunService       = game:GetService("RunService")
    local PhysicsService   = game:GetService("PhysicsService")
    local lp               = Players.LocalPlayer

    local SPIN_SPEED = 25000

    local isActive       = false
    local bav            = nil
    local noclipConn     = nil
    local antiflingConn  = nil
    local isEquipped     = false
    local isRamping      = false
    local savedWalk      = 16    -- آخر قيمة WalkSpeed محفوظة قبل التجميد
    local savedJump      = 50    -- آخر قيمة JumpPower محفوظة قبل التجميد

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = "Cryptic", Text = text, Duration = 2 })
        end)
    end

    local function GetRoot(char)
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    -- ==========================================
    -- أنتي فلينج صامت (يشتغل بمجرد تفعيل الزر)
    -- ==========================================
    local function StartAntifling()
        if antiflingConn then antiflingConn:Disconnect() end
        antiflingConn = RunService.Stepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    for _, part in pairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end

    local function StopAntifling()
        if antiflingConn then antiflingConn:Disconnect(); antiflingConn = nil end
    end

    -- ==========================================
    -- فحص دعم الماب للتلامس
    -- ==========================================
    local function CheckCollisionAllowed()
        local char = lp.Character
        if not char then return true end
        local myTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if not myTorso then return true end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local tgt = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
                if tgt then
                    local ok, can = pcall(function()
                        return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, tgt.CollisionGroup)
                    end)
                    if ok and not can then return false end
                end
            end
        end
        return true
    end

    -- ==========================================
    -- تجميد / تحرير اللاعب
    -- ==========================================
    local function LockPlayer(char)
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        local hrp = GetRoot(char)
        if not hum or not hrp then return savedWalk, savedJump end

        -- احفظ القيم على مستوى الوحدة قبل التجميد
        savedWalk = hum.WalkSpeed > 0 and hum.WalkSpeed or savedWalk
        savedJump = hum.JumpPower > 0 and hum.JumpPower or savedJump

        hum.WalkSpeed = 0
        hum.JumpPower = 0
        pcall(function() hum.JumpHeight = 0 end)

        local old = hrp:FindFirstChild("CrypticLockBV")
        if old then old:Destroy() end
        local bv = Instance.new("BodyVelocity")
        bv.Name     = "CrypticLockBV"
        bv.Velocity  = Vector3.new(0, 0, 0)
        bv.MaxForce  = Vector3.new(math.huge, 0, math.huge)
        bv.Parent    = hrp

        return savedWalk, savedJump
    end

    -- يضمن إعادة التحكم دائماً — يُستدعى حتى لو صار خطأ في التسلسل
    local function UnlockPlayer(char, w, j)
        local walk = w or savedWalk or 16
        local jump = j or savedJump or 50
        local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
        local hrp  = GetRoot(char)
        pcall(function()
            if hum then
                hum.WalkSpeed = walk
                hum.JumpPower = jump
                hum.JumpHeight = 7.2
            end
        end)
        pcall(function()
            if hrp then
                local bv = hrp:FindFirstChild("CrypticLockBV")
                if bv then bv:Destroy() end
            end
        end)
    end

    -- ==========================================
    -- تهيئة فيزياء الفلينج
    -- ==========================================
    local function ApplyFlingPhysics(char)
        local hrp = GetRoot(char)
        if not hrp then return end

        -- كثافة عالية
        for _, child in pairs(char:GetDescendants()) do
            if child:IsA("BasePart") then
                pcall(function()
                    child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
                end)
            end
        end

        task.wait(0.05)

        -- NoClip + Massless
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                pcall(function()
                    v.CanCollide = false
                    v.Massless   = true
                    v.Velocity   = Vector3.new(0, 0, 0)
                end)
            end
        end

        -- BodyGyro: يثبّت الشخصية مستقيمة (يمنع الانقلاب) ويسمح فقط بدوران Y
        local oldGyro = hrp:FindFirstChild("CrypticFlingGyro")
        if oldGyro then oldGyro:Destroy() end
        local gyro = Instance.new("BodyGyro")
        gyro.Name      = "CrypticFlingGyro"
        gyro.MaxTorque = Vector3.new(math.huge, 0, math.huge) -- يقفل X وZ، يترك Y للـ BAV
        gyro.P         = 8000
        gyro.D         = 300
        gyro.CFrame    = CFrame.new()    -- توجيه مستقيم
        gyro.Parent    = hrp

        -- BAV بسرعة صفر (يُفعَّل لاحقاً بالرمب)
        local old = hrp:FindFirstChild("CrypticFlingBAV")
        if old then old:Destroy() end
        bav                 = Instance.new("BodyAngularVelocity")
        bav.Name            = "CrypticFlingBAV"
        bav.AngularVelocity = Vector3.new(0, 0, 0)
        bav.MaxTorque       = Vector3.new(0, 0, 0)
        bav.P               = math.huge
        bav.Parent          = hrp

        -- لوب NoClip
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            local c = lp.Character
            if not c then return end
            for _, v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
            -- حافظ على توجيه الجايرو مستقيماً في كل فريم
            local h = GetRoot(c)
            local g = h and h:FindFirstChild("CrypticFlingGyro")
            if g then
                pcall(function()
                    g.CFrame = CFrame.new(h.CFrame.Position)
                end)
            end
        end)

        -- لوب نبضات الدوران
        task.spawn(function()
            while bav and bav.Parent and isActive do
                if not isRamping then
                    pcall(function() bav.AngularVelocity = Vector3.new(0, SPIN_SPEED, 0) end)
                    pcall(function() bav.MaxTorque = Vector3.new(0, math.huge, 0) end)
                    task.wait(0.25)
                    if not isRamping then
                        pcall(function() bav.AngularVelocity = Vector3.new(0, 0, 0) end)
                    end
                    task.wait(0.1)
                else
                    task.wait(0.05)
                end
            end
        end)
    end

    local function RemoveFling(char)
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        if bav then pcall(function() bav:Destroy() end); bav = nil end
        if char then
            local hrp = GetRoot(char)
            if hrp then
                for _, v in pairs(hrp:GetChildren()) do
                    if v.Name == "CrypticFlingBAV"
                    or v.Name == "CrypticCarryBP"
                    or v.Name == "CrypticLockBV"
                    or v.Name == "CrypticFlingGyro" then
                        pcall(function() v:Destroy() end)
                    end
                end
            end
            for _, child in pairs(char:GetDescendants()) do
                if child:IsA("BasePart") then
                    pcall(function()
                        child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                        child.CanCollide = true
                        child.Massless   = false
                    end)
                end
            end
        end
    end

    -- ==========================================
    -- تسلسل التجهيز: تجميد ← رفع ← رمب دوران ← نزول ← تحرير
    -- ==========================================
    local function EquipSequence(char)
        task.spawn(function()
            local hrp = GetRoot(char)
            if not hrp then return end

            isRamping = true
            local prevWalk, prevJump = LockPlayer(char)

            local ok = pcall(function()
                local startPos = hrp.Position

                local bp      = Instance.new("BodyPosition")
                bp.Name       = "CrypticCarryBP"
                bp.P          = 11000
                bp.D          = 850
                bp.MaxForce   = Vector3.new(0, math.huge, 0)
                bp.Position   = startPos + Vector3.new(0, 2.5, 0)
                bp.Parent     = hrp
                task.wait(0.25)

                if bav and bav.Parent then
                    local steps = 12
                    for i = 1, steps do
                        if not isEquipped then break end
                        local t = i / steps
                        pcall(function()
                            bav.AngularVelocity = Vector3.new(0, SPIN_SPEED * t, 0)
                            bav.MaxTorque       = Vector3.new(0, math.huge, 0)
                        end)
                        task.wait(0.28 / steps)
                    end
                end

                bp.Position = startPos
                task.wait(0.22)

                pcall(function() bp:Destroy() end)
                pcall(function() local v=hrp.AssemblyLinearVelocity; hrp.AssemblyLinearVelocity=Vector3.new(v.X,-9,v.Z) end)
                task.wait(0.07)
                pcall(function() local v=hrp.AssemblyLinearVelocity; hrp.AssemblyLinearVelocity=Vector3.new(v.X,5,v.Z) end)
                task.wait(0.09)
                pcall(function() local v=hrp.AssemblyLinearVelocity; hrp.AssemblyLinearVelocity=Vector3.new(v.X,0,v.Z) end)
            end)

            isRamping = false
            -- مضمون: يُعيد التحكم حتى لو صار خطأ في التسلسل
            UnlockPlayer(char, prevWalk, prevJump)
        end)
    end

    -- ==========================================
    -- تسلسل الخلع (أقل من ثانية)
    -- ==========================================
    local function UnequipSequence(char)
        isEquipped = false
        isRamping  = true

        task.spawn(function()
            local hrp = GetRoot(char)
            -- لو ما في HRP: أعد التحكم فوراً وأزل كل شيء
            if not hrp then
                UnlockPlayer(char, savedWalk, savedJump)
                RemoveFling(char)
                isRamping = false
                return
            end

            local prevWalk, prevJump = LockPlayer(char)

            -- pcall يضمن وصول UnlockPlayer حتى لو صار خطأ
            pcall(function()
                local startPos = hrp.Position

                -- إيقاف الدوران (0.12 ث)
                if bav and bav.Parent then
                    local steps = 8
                    for i = steps, 0, -1 do
                        pcall(function()
                            bav.AngularVelocity = Vector3.new(0, SPIN_SPEED * (i / steps), 0)
                        end)
                        task.wait(0.12 / steps)
                    end
                    pcall(function() bav.MaxTorque = Vector3.new(0, 0, 0) end)
                end

                local bp      = Instance.new("BodyPosition")
                bp.Name       = "CrypticCarryBP"
                bp.P          = 13000
                bp.D          = 950
                bp.MaxForce   = Vector3.new(0, math.huge, 0)
                bp.Position   = startPos + Vector3.new(0, 1.5, 0)
                bp.Parent     = hrp
                task.wait(0.17)

                bp.Position = startPos
                task.wait(0.15)

                pcall(function() bp:Destroy() end)
                pcall(function() local v=hrp.AssemblyLinearVelocity; hrp.AssemblyLinearVelocity=Vector3.new(v.X,-6,v.Z) end)
                task.wait(0.06)
                pcall(function() local v=hrp.AssemblyLinearVelocity; hrp.AssemblyLinearVelocity=Vector3.new(v.X,4,v.Z) end)
                task.wait(0.07)
                pcall(function() local v=hrp.AssemblyLinearVelocity; hrp.AssemblyLinearVelocity=Vector3.new(v.X,0,v.Z) end)
            end)

            -- مضمون دائماً حتى لو أي شيء فشل فوق
            UnlockPlayer(char, prevWalk, prevJump)
            RemoveFling(char)
            isRamping = false

            -- قفزة واحدة بعد رجوع التحكم
            task.wait(0.05)
            pcall(function()
                local h = GetRoot(lp.Character)
                if h then
                    h.AssemblyLinearVelocity = Vector3.new(
                        h.AssemblyLinearVelocity.X,
                        50,
                        h.AssemblyLinearVelocity.Z
                    )
                end
            end)
        end)
    end

    -- ==========================================
    -- واتشدوج: يفحص كل ثانية ويعيد التحكم تلقائياً
    -- لو الأداة مش مجهّزة ولكن WalkSpeed = 0
    -- ==========================================
    task.spawn(function()
        while true do
            task.wait(1)
            if isActive and not isEquipped and not isRamping then
                local char = lp.Character
                local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
                if hum and hum.WalkSpeed == 0 then
                    -- الشخصية مجمّدة بدون سبب → أعد التحكم
                    UnlockPlayer(char, savedWalk, savedJump)
                end
            end
        end
    end)

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
        tool.ToolTip        = "Cryptic Hub | Fling Tool"
        tool.Parent         = backpack

        tool.Equipped:Connect(function()
            isEquipped = true
            local c = lp.Character
            if not c then return end
            ApplyFlingPhysics(c)
            EquipSequence(c)
        end)

        tool.Unequipped:Connect(function()
            UnequipSequence(lp.Character)
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
        btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Text = "Fling"
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
                if eq then btn.BackgroundColor3=Color3.fromRGB(0,180,80); btn.Text="Fling ON"
                else btn.BackgroundColor3=Color3.fromRGB(200,50,0); btn.Text="Fling" end
                task.wait(0.2)
            end
        end)
    end

    local function Cleanup()
        local char=lp.Character
        isEquipped = false; isRamping = false
        StopAntifling()
        RemoveFling(char)
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.WalkSpeed=16; hum.JumpPower=50; pcall(function() hum.JumpHeight=7.2 end) end
        local ui=lp.PlayerGui:FindFirstChild("CrypticFlingUI"); if ui then ui:Destroy() end
        local inB=lp.Backpack:FindFirstChild("Cryptic Fling"); local inC=char and char:FindFirstChild("Cryptic Fling")
        if inB then inB:Destroy() end; if inC then inC:Destroy() end
    end

    lp.CharacterAdded:Connect(function(newChar)
        if isActive then
            isEquipped = false; isRamping = false
            task.wait(1.5)
            local t=CreateFlingTool(newChar); if t then EnforceSlot(t) end
        end
    end)

    -- ==========================================
    -- Toggle
    -- ==========================================
    Tab:AddToggle("أداة الفلينج / Fling Tool", function(active)
        isActive = active
        if active then
            if not CheckCollisionAllowed() then
                isActive = false
                Notify("الماب لا يدعم التلامس / Map has no collision")
                return
            end
            -- تشغيل أنتي فلينج صامت فوراً بدون إشعار
            StartAntifling()
            local char=lp.Character
            local t=CreateFlingTool(char); if t then EnforceSlot(t) end
            EnsureFloatingUI()
            Notify("فلينج ON — جهّز الأداة / Equip the tool")
        else
            Cleanup()
            Notify("فلينج OFF")
        end
    end)
end
