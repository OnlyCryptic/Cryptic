return function(Tab, UI)
local i18n = getgenv().CrypticI18n
local T = (i18n and i18n.T) or function(k) return k end

local Players = game:GetService("Players") 
local RunService = game:GetService("RunService") 
local PhysicsService = game:GetService("PhysicsService") 
local StarterGui = game:GetService("StarterGui") 
local lp = Players.LocalPlayer 

local ZERO_VEC = Vector3.zero 
local FLING_UP = Vector3.new(0, 10000, 0)
local MOVE_UP = Vector3.new(0, 0.1, 0)
local MOVE_DOWN = Vector3.new(0, -0.1, 0)

local function Notify(title, body) 
    pcall(function() 
        StarterGui:SetCore("SendNotification", { Title = title, Text = body, Duration = 4 }) 
    end) 
end 

local function CheckCollisionAllowed() 
    local isAllowed = true 
    local myChar = lp.Character 
    if not myChar then return true end 
    local myTorso = myChar:FindFirstChild("UpperTorso") or myChar:FindFirstChild("Torso") 
    local playersList = Players:GetPlayers()

    for i = 1, #playersList do 
        local p = playersList[i]
        if p ~= lp and p.Character then 
            local tgtTorso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso") 
            if myTorso and tgtTorso then 
                local ok, can = pcall(function() return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, tgtTorso.CollisionGroup) end) 
                if ok and not can then isAllowed = false break end 
            end 
        end 
    end 
    return isAllowed 
end 

local TweenService = game:GetService("TweenService") 
local function Tw(obj, props, t) 
    TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() 
end 

local ACCENT = Color3.fromRGB(0, 255, 150) 
local ACCENT2 = Color3.fromRGB(0, 150, 255) 
local OFF_CLR = Color3.fromRGB(45, 45, 55) 

local function AddAutoOffToggle(label, callback) 
    Tab.Order = Tab.Order or 0 
    Tab.Order = Tab.Order + 1 
    local ParentPage = Tab.Page or Tab.Container or Tab 
    local R = Instance.new("Frame", ParentPage) 
    R.LayoutOrder = Tab.Order 
    R.Size = UDim2.new(0.98, 0, 0, 46) 
    R.BackgroundColor3 = Color3.fromRGB(16, 16, 20) 
    R.BackgroundTransparency = 0.1 
    Instance.new("UICorner", R).CornerRadius = UDim.new(0, 10) 
    local Stroke = Instance.new("UIStroke", R) 
    Stroke.Thickness = 1.2 
    Stroke.Transparency = 0.55 
    local Grad = Instance.new("UIGradient", Stroke) 
    Grad.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, ACCENT), ColorSequenceKeypoint.new(1, ACCENT2) } 
    Grad.Rotation = 45 
    local Lbl = Instance.new("TextLabel", R) 
    Lbl.Text = label 
    Lbl.Size = UDim2.new(1, -65, 1, 0) 
    Lbl.Position = UDim2.new(0, 10, 0, 0) 
    Lbl.TextColor3 = Color3.fromRGB(210, 210, 225) 
    Lbl.BackgroundTransparency = 1 
    Lbl.TextXAlignment = Enum.TextXAlignment.Left 
    Lbl.Font = Enum.Font.GothamSemibold 
    Lbl.TextSize = 11 
    Lbl.TextWrapped = false 
    local Track = Instance.new("Frame", R) 
    Track.Size = UDim2.new(0, 44, 0, 22) 
    Track.Position = UDim2.new(1, -54, 0.5, -11) 
    Track.BackgroundColor3 = OFF_CLR 
    Track.BorderSizePixel = 0 
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0) 
    local Knob = Instance.new("Frame", Track) 
    Knob.Size = UDim2.new(0, 16, 0, 16) 
    Knob.Position = UDim2.new(0, 3, 0.5, -8) 
    Knob.BackgroundColor3 = Color3.fromRGB(200, 200, 215) 
    Knob.BorderSizePixel = 0 
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0) 
    local B = Instance.new("TextButton", R) 
    B.Size = UDim2.new(1, 0, 1, 0) 
    B.BackgroundTransparency = 1 
    B.Text = "" 
    B.AutoButtonColor = false 
    B.MouseEnter:Connect(function() Tw(R, {BackgroundTransparency = 0}, 0.12) end) 
    B.MouseLeave:Connect(function() Tw(R, {BackgroundTransparency = 0.1}, 0.12) end) 
    local isActive = false 
    local configKey = (Tab.TabName or "Tab") .. "_" .. label 
    local function setState(state, isManual) 
        if state == true and not CheckCollisionAllowed() then 
            Notify("Cryptic Hub", T("player.walkfling.no_collision")) 
            return 
        end 
        isActive = state 
        if isActive then 
            Tw(Track, {BackgroundColor3 = ACCENT}, 0.18) 
            Tw(Knob, {Position = UDim2.new(0, 25, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.18) 
            Tw(Stroke, {Transparency = 0.1}, 0.18) 
        else 
            Tw(Track, {BackgroundColor3 = OFF_CLR}, 0.18) 
            Tw(Knob, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(200,200,215)}, 0.18) 
            Tw(Stroke, {Transparency = 0.55}, 0.18) 
        end 
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
                    Notify("Cryptic Hub", T("player.walkfling.death_off")) 
                end 
            end) 
        end 
    end 
    if lp.Character then task.spawn(function() setupDeathEvent(lp.Character) end) end 
    lp.CharacterAdded:Connect(setupDeathEvent) 
    return { SetState = function(self, state) setState(state, false) end } 
end 

-- =========================================================================== 
-- نظام إدارة الأجزاء (الكاش)
-- =========================================================================== 
local myParts = {} 
local othersMap = {} 
local flatOthersParts = {} 

local function rebuildFlatOthers()
    table.clear(flatOthersParts)
    for _, parts in pairs(othersMap) do
        local partsCount = #parts
        for i = 1, partsCount do
            flatOthersParts[#flatOthersParts + 1] = parts[i]
        end
    end
end

local function collectParts(char) 
    local list = {} 
    if not char then return list end 
    local descendants = char:GetDescendants()
    local descCount = #descendants
    for i = 1, descCount do 
        local d = descendants[i]
        if d:IsA("BasePart") then 
            list[#list + 1] = d 
        end 
    end 
    return list 
end 

local function bindMyCharacter(char) 
    myParts = collectParts(char) 
    local addedConn, removingConn

    addedConn = char.DescendantAdded:Connect(function(d) 
        if d:IsA("BasePart") then myParts[#myParts + 1] = d end 
    end) 

    removingConn = char.DescendantRemoving:Connect(function(d)
        if d:IsA("BasePart") then
            for i = #myParts, 1, -1 do
                if myParts[i] == d then 
                    table.remove(myParts, i) 
                    break 
                end
            end
        end
    end)

    char.Destroying:Connect(function()
        addedConn:Disconnect()
        removingConn:Disconnect()
    end)
end 

local function bindOtherCharacter(p, char) 
    if p == lp or not char then return end 
    local parts = collectParts(char) 
    othersMap[p] = parts 
    rebuildFlatOthers()

    local addedConn, removingConn
    addedConn = char.DescendantAdded:Connect(function(d) 
        if d:IsA("BasePart") then 
            parts[#parts + 1] = d 
            rebuildFlatOthers()
        end 
    end) 

    removingConn = char.DescendantRemoving:Connect(function(d)
        if d:IsA("BasePart") then
            for i = #parts, 1, -1 do
                if parts[i] == d then 
                    table.remove(parts, i) 
                    break 
                end
            end
            rebuildFlatOthers()
        end
    end)

    char.Destroying:Connect(function()
        addedConn:Disconnect()
        removingConn:Disconnect()
        if othersMap[p] == parts then
            othersMap[p] = nil
            rebuildFlatOthers()
        end
    end)
end 

lp.CharacterAdded:Connect(bindMyCharacter) 
if lp.Character then task.spawn(bindMyCharacter, lp.Character) end 

for _, p in ipairs(Players:GetPlayers()) do 
    if p ~= lp then 
        p.CharacterAdded:Connect(function(char) bindOtherCharacter(p, char) end) 
        if p.Character then bindOtherCharacter(p, p.Character) end 
    end 
end 

Players.PlayerAdded:Connect(function(p) 
    p.CharacterAdded:Connect(function(char) bindOtherCharacter(p, char) end) 
end) 

Players.PlayerRemoving:Connect(function(p) 
    if othersMap[p] then
        othersMap[p] = nil 
        rebuildFlatOthers()
    end
end) 

-- State 
local walkflinging = false 
local stepConn = nil 
local flingThread = nil 

local function StopAll() 
    walkflinging = false 
    if stepConn then stepConn:Disconnect() stepConn = nil end 
    if flingThread then task.cancel(flingThread) flingThread = nil end 
end 

local walkFlingToggle 
walkFlingToggle = AddAutoOffToggle(T("player.walkfling.label"), function(active, isManual) 
    if active then 
        walkflinging = true 
        Notify(T("player.walkfling.on_title"), T("player.walkfling.on_body")) 

        local frameToggle = false -- مفتاح التناوب بين الإطارات لتقليل الحمل الجسيم

        stepConn = RunService.Stepped:Connect(function() 
            if not walkflinging then return end 

            -- 1. فحص الـ Noclip الخاص بك (يجب أن يعمل كل إطار لضمان عدم ثباتك بالأرض)
            local myCount = #myParts
            for i = 1, myCount do 
                local part = myParts[i]
                if part and part.Parent then part.CanCollide = false end 
            end 

            -- 2. [التحسين الحقيقي]: تجميد فيزياء الخصوم إطار بعد إطار (Throttling)
            -- هذا يقطع استهلاك المحرك الفيزيائي إلى النصف دون التأثير على جودة الفلينج
            frameToggle = not frameToggle
            if frameToggle then
                local flatCount = #flatOthersParts
                for i = 1, flatCount do 
                    local part = flatOthersParts[i] 
                    if part and part.Parent then 
                        part.CanCollide = false 
                        part.AssemblyLinearVelocity = ZERO_VEC 
                        part.AssemblyAngularVelocity = ZERO_VEC 
                    end 
                end 
            end
        end) 

        flingThread = task.spawn(function() 
            local useFlingUp = true
            while walkflinging do 
                RunService.Heartbeat:Wait() 
                local char = lp.Character 
                local root = char and char:FindFirstChild("HumanoidRootPart") 
                if root and root.Parent then 
                    local vel = root.AssemblyLinearVelocity 

                    -- تطبيق القوة الطاردة الكبرى
                    root.AssemblyLinearVelocity = (vel * 10000) + FLING_UP 

                    RunService.RenderStepped:Wait() 
                    if root and root.Parent then root.AssemblyLinearVelocity = vel end 

                    RunService.Stepped:Wait() 
                    if root and root.Parent then 
                        root.AssemblyLinearVelocity = vel + (useFlingUp and MOVE_UP or MOVE_DOWN)
                        useFlingUp = not useFlingUp
                    end 
                end 
            end 
        end) 
    else 
        StopAll() 
        if isManual then 
            local hum = lp.Character and lp.Character:FindFirstChild("Humanoid") 
            if hum and hum.Health > 0 then 
                hum.Health = 0 
                Notify("Cryptic Hub", T("player.walkfling.resetting")) 
            end 
        end 
    end 
end) 

end