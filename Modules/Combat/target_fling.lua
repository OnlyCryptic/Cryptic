-- [[ Cryptic Hub - تطيير الهدف (SkidFling Method) ]]

return function(Tab, UI)
    local Players        = game:GetService("Players")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui     = game:GetService("StarterGui")
    local LocalPlayer    = Players.LocalPlayer

    local isFlinging = false
    local savedCFrame = nil

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = "Cryptic",
                Text     = ar .. " / " .. en,
                Duration = 3,
            })
        end)
    end

    local function MapSupportsCollision(hrp)
        local ok, col = pcall(function()
            return PhysicsService:CollisionGroupsAreCollidable(
                hrp.CollisionGroup, hrp.CollisionGroup)
        end)
        return not ok or col
    end

    -- ==========================================
    -- دالة التطيير الأساسية (SkidFling)
    -- ==========================================
    local function SkidFling(targetPlayer)
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = hum and hum.RootPart
        if not char or not hum or not root then return end

        local tChar = targetPlayer.Character
        if not tChar then return end

        local tHum    = tChar:FindFirstChildOfClass("Humanoid")
        local tRoot   = tHum and tHum.RootPart
        local tHead   = tChar:FindFirstChild("Head")
        local acc     = tChar:FindFirstChildOfClass("Accessory")
        local handle  = acc and acc:FindFirstChild("Handle")

        if not tChar:FindFirstChildWhichIsA("BasePart") then return end
        if tHum and tHum.Sit then return end

        -- احفظ موقعك إذا كانت سرعتك طبيعية
        if root.Velocity.Magnitude < 50 then
            savedCFrame = root.CFrame
        end

        -- وجّه الكاميرا للهدف مؤقتاً
        pcall(function()
            workspace.CurrentCamera.CameraSubject = tHead or handle or tHum
        end)

        -- منع الموت من الفراغ أثناء الانتقال
        local fpdh = workspace.FallenPartsDestroyHeight
        workspace.FallenPartsDestroyHeight = 0/0

        -- BodyVelocity يمسكك ثابتاً بين الانتقالات
        local bv = Instance.new("BodyVelocity")
        bv.Velocity  = Vector3.new(0, 0, 0)
        bv.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent    = root

        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        -- انتقل لموقع الهدف وطبّق سرعة هائلة
        local function FPos(basePart, pos, ang)
            local cf = CFrame.new(basePart.Position) * pos * ang
            pcall(function() root.CFrame = cf end)
            pcall(function() char:SetPrimaryPartCFrame(cf) end)
            root.Velocity    = Vector3.new(9e7, 9e7 * 10, 9e7)
            root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        -- حلقة التطيير حول قطعة الهدف
        local function SFBasePart(basePart)
            local startTime = tick()
            local angle     = 0
            repeat
                if not root or not tHum then break end
                if basePart.Velocity.Magnitude < 50 then
                    angle = angle + 100
                    FPos(basePart, CFrame.new(0,  1.5, 0) + tHum.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0) + tHum.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0,  1.5, 0) + tHum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0) + tHum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                else
                    FPos(basePart, CFrame.new(0,  1.5,  tHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, -tHum.WalkSpeed), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0,  1.5,  tHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                end
            until tick() - startTime > 2 or not isFlinging
        end

        -- طبّق على أفضل قطعة متاحة
        if tRoot then
            SFBasePart(tRoot)
        elseif tHead then
            SFBasePart(tHead)
        elseif handle then
            SFBasePart(handle)
        end

        -- تنظيف
        pcall(function() bv:Destroy() end)
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        pcall(function() workspace.CurrentCamera.CameraSubject = hum end)

        -- ارجع لموقعك الأصلي
        if savedCFrame then
            local attempts = 0
            repeat
                pcall(function()
                    root.CFrame = savedCFrame * CFrame.new(0, 0.5, 0)
                    char:SetPrimaryPartCFrame(savedCFrame * CFrame.new(0, 0.5, 0))
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Velocity    = Vector3.new()
                            part.RotVelocity = Vector3.new()
                        end
                    end
                end)
                task.wait()
                attempts += 1
            until (root.Position - savedCFrame.p).Magnitude < 25 or attempts > 20
        end

        workspace.FallenPartsDestroyHeight = fpdh
    end

    -- ==========================================
    -- زر التفعيل
    -- ==========================================
    Tab:AddToggle("تطيير الهدف / Fling Target", function(active)
        isFlinging = active

        if active then
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isFlinging = false
                Notify("حدد لاعباً أولاً", "Select a player first")
                return
            end

            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and not MapSupportsCollision(root) then
                isFlinging = false
                Notify("الماب لا يدعم التلامس", "Map has no collision")
                return
            end

            Notify("يبدأ التطيير", "Starting fling")

            task.spawn(function()
                while isFlinging do
                    if _G.ArwaTarget and _G.ArwaTarget.Character then
                        SkidFling(_G.ArwaTarget)
                        task.wait(0.5)
                    else
                        task.wait(0.1)
                    end
                end
            end)
        else
            Notify("توقف", "Fling stopped")
        end
    end)
end
