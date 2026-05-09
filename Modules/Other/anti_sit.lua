-- [[ Cryptic Hub - Anti Sit ]]
-- يمنع الكراسي والمركبات (Seat / VehicleSeat) من قبضك أصلاً
-- بيعطّلها محلياً (Disabled = true) فما تفتح ولا مرة
-- لو حصل وقبض كرسي بأي طريقة، بنطلعك على طول
-- يسمح بالجلوس في الهواء أو شيء غير ملموس (إيموتات / سكربتات تخصصية)
-- Localized via i18n. الكي: other.anti_sit.*

local i18n = getgenv().CrypticI18n
local T    = (i18n and i18n.T) or function(k) return k end

return function(Tab, UI)
    local Players    = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local RunService = game:GetService("RunService")
    local lp         = Players.LocalPlayer

    local enabled        = false
    local seatedConn     = nil
    local seatPartConn   = nil
    local heartbeatConn  = nil
    local charAddedConn  = nil
    local descAddedConn  = nil

    local originalState = {}      -- [seat] = original .Disabled
    local trackedSeats  = {}      -- [seat] = true

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = "Cryptic Hub",
                Text     = text,
                Duration = 3,
            })
        end)
    end

    local function IsRealSeat(part)
        return part and (part:IsA("Seat") or part:IsA("VehicleSeat"))
    end

    local function DisableSeat(seat)
        if not seat or trackedSeats[seat] then return end
        trackedSeats[seat] = true
        pcall(function()
            originalState[seat] = seat.Disabled
            seat.Disabled = true
        end)
        -- لو شيء حاول يرجعها false، نرجع نعطّلها
        pcall(function()
            seat.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    trackedSeats[seat] = nil
                    originalState[seat] = nil
                end
            end)
        end)
    end

    local function RestoreSeat(seat)
        if not seat then return end
        pcall(function()
            seat.Disabled = originalState[seat] or false
        end)
        trackedSeats[seat] = nil
        originalState[seat] = nil
    end

    local function DisableAllSeats()
        for _, inst in ipairs(workspace:GetDescendants()) do
            if IsRealSeat(inst) then
                DisableSeat(inst)
            end
        end
    end

    local function RestoreAllSeats()
        for seat in pairs(trackedSeats) do
            RestoreSeat(seat)
        end
        originalState = {}
        trackedSeats  = {}
    end

    -- إزالة الـ SeatWeld اللي بيربط اللاعب بالكرسي (دفاع احتياطي)
    local function BreakSeatWeld(seat, character)
        if not seat then return end
        pcall(function()
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            for _, child in ipairs(seat:GetChildren()) do
                if child:IsA("Weld") or child:IsA("WeldConstraint") then
                    if hrp and (child.Part0 == hrp or child.Part1 == hrp) then
                        child:Destroy()
                    elseif child.Name == "SeatWeld" then
                        child:Destroy()
                    end
                end
            end
        end)
    end

    -- خط دفاع ثاني: لو حصل وقبض كرسي، بنطلعك بكل الطرق
    local function ForceUnsit(humanoid, seatPart)
        if not humanoid then return end
        local character = humanoid.Parent

        BreakSeatWeld(seatPart or humanoid.SeatPart, character)
        pcall(function() humanoid.Sit = false end)
        pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)

        pcall(function()
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 30, hrp.AssemblyLinearVelocity.Z)
            end
        end)
    end

    local function HookCharacter(character)
        if not enabled or not character then return end
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end

        if humanoid.Sit and IsRealSeat(humanoid.SeatPart) then
            ForceUnsit(humanoid, humanoid.SeatPart)
        end

        if seatedConn   then seatedConn:Disconnect()   end
        if seatPartConn then seatPartConn:Disconnect() end

        seatedConn = humanoid.Seated:Connect(function(active, seatPart)
            if not enabled then return end
            if not active then return end
            if IsRealSeat(seatPart) then
                ForceUnsit(humanoid, seatPart)
            end
        end)

        seatPartConn = humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
            if not enabled then return end
            if IsRealSeat(humanoid.SeatPart) then
                ForceUnsit(humanoid, humanoid.SeatPart)
            end
        end)
    end

    Tab:AddToggle(T("other.anti_sit.label"), function(state)
        enabled = state
        if enabled then
            -- 1) عطّل كل الكراسي الموجودة
            DisableAllSeats()

            -- 2) عطّل أي كرسي جديد ينضاف للماب
            if descAddedConn then descAddedConn:Disconnect() end
            descAddedConn = workspace.DescendantAdded:Connect(function(inst)
                if not enabled then return end
                if IsRealSeat(inst) then
                    DisableSeat(inst)
                end
            end)

            -- 3) Heartbeat بيتأكد إن الكراسي ضلت معطّلة (لو السيرفر رجع فعّلها)
            if heartbeatConn then heartbeatConn:Disconnect() end
            heartbeatConn = RunService.Heartbeat:Connect(function()
                if not enabled then return end
                for seat in pairs(trackedSeats) do
                    if seat and seat.Parent and not seat.Disabled then
                        pcall(function() seat.Disabled = true end)
                    end
                end
            end)

            -- 4) ربط شخصيتك للحراسة
            HookCharacter(lp.Character)
            if charAddedConn then charAddedConn:Disconnect() end
            charAddedConn = lp.CharacterAdded:Connect(function(char)
                task.wait(0.3)
                HookCharacter(char)
            end)

            Notify(T("other.anti_sit.on"))
        else
            if seatedConn    then seatedConn:Disconnect()    seatedConn    = nil end
            if seatPartConn  then seatPartConn:Disconnect()  seatPartConn  = nil end
            if heartbeatConn then heartbeatConn:Disconnect() heartbeatConn = nil end
            if charAddedConn then charAddedConn:Disconnect() charAddedConn = nil end
            if descAddedConn then descAddedConn:Disconnect() descAddedConn = nil end
            RestoreAllSeats()
            Notify(T("other.anti_sit.off"))
        end
    end)
end
