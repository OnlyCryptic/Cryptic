-- [[ Cryptic Hub - كشف الهدف فقط (Target ESP) ]]
-- الإصلاح: يُعاد تطبيق الـ ESP تلقائياً بعد كل ريسبون للهدف

return function(Tab, UI)
    local Players    = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp         = Players.LocalPlayer

    local espActive  = false      -- هل الـ ESP مفعّل حالياً؟
    local espData    = {}         -- { Highlight, Billboard, TextLabel }
    local renderConn = nil        -- لوب تحديث المسافة
    local charConn   = nil        -- مستمع CharacterAdded على الهدف

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text  = ar .. "\n" .. en,
                Duration = 4,
            })
        end)
    end

    -- تنظيف الـ ESP من الشخصية الحالية فقط (لا يوقف اللوب)
    local function ClearESPObjects()
        if espData.Highlight then pcall(function() espData.Highlight:Destroy() end) end
        if espData.Billboard then pcall(function() espData.Billboard:Destroy() end) end
        espData = {}
    end

    -- تنظيف كامل (يوقف كل شيء)
    local function RemoveESP()
        espActive = false
        ClearESPObjects()
        if renderConn then renderConn:Disconnect() renderConn = nil end
        if charConn   then charConn:Disconnect()   charConn   = nil end
    end

    -- تطبيق الـ ESP على شخصية معيّنة
    local function ApplyESPToChar(plr, char)
        -- انتظر تحميل الشخصية كاملاً
        task.wait(0.3)
        if not char or not char.Parent then return end
        if not espActive then return end

        ClearESPObjects()

        pcall(function()
            -- Highlight (يظهر من خلال الجدران)
            if not char:FindFirstChild("CrypticTargetESP_H") then
                local h = Instance.new("Highlight", char)
                h.Name                = "CrypticTargetESP_H"
                h.FillColor           = Color3.fromRGB(255, 50, 50)
                h.OutlineColor        = Color3.fromRGB(255, 255, 255)
                h.FillTransparency    = 0.35
                h.OutlineTransparency = 0
                espData.Highlight = h
            end

            -- BillboardGui (اسم + مسافة)
            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if head and not head:FindFirstChild("CrypticTargetESP_BB") then
                local bb = Instance.new("BillboardGui", head)
                bb.Name          = "CrypticTargetESP_BB"
                bb.AlwaysOnTop   = true
                bb.MaxDistance   = math.huge
                bb.ExtentsOffset = Vector3.new(0, 3.5, 0)
                bb.Size          = UDim2.new(0, 220, 0, 55)

                local lbl = Instance.new("TextLabel", bb)
                lbl.Size                   = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text                   = "🎯 " .. plr.DisplayName .. " [?]"
                lbl.TextColor3             = Color3.fromRGB(255, 80, 80)
                lbl.TextSize               = 15
                lbl.Font                   = Enum.Font.GothamBold
                lbl.TextStrokeTransparency = 0
                lbl.TextStrokeColor3       = Color3.new(0, 0, 0)

                espData.Billboard = bb
                espData.TextLabel = lbl
            end
        end)
    end

    -- تشغيل الـ ESP كاملاً على لاعب معيّن
    local function StartESP(plr)
        espActive = true

        -- طبّق على الشخصية الحالية
        if plr.Character then
            task.spawn(ApplyESPToChar, plr, plr.Character)
        end

        -- استمع لكل ريسبون ✅ هذا هو الإصلاح
        if charConn then charConn:Disconnect() end
        charConn = plr.CharacterAdded:Connect(function(newChar)
            if espActive then
                task.spawn(ApplyESPToChar, plr, newChar)
            end
        end)

        -- لوب تحديث المسافة على الشاشة
        if renderConn then renderConn:Disconnect() end
        renderConn = RunService.RenderStepped:Connect(function()
            if not espActive then return end

            local target = _G.ArwaTarget
            if not target then return end

            local tChar = target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            local lpChar = lp.Character
            local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")

            -- تحديث النص فقط إذا الشخصية حية
            if espData.TextLabel and tRoot and lpRoot then
                local dist = math.floor((lpRoot.Position - tRoot.Position).Magnitude)
                espData.TextLabel.Text = "🎯 " .. target.DisplayName .. " [" .. dist .. "m]"
            end
        end)
    end

    Tab:AddToggle("مكان هدف / Target ESP", function(active)
        if active then
            local target = _G.ArwaTarget
            if not target or not target.Character then
                Notify("⚠️ حدد لاعباً أولاً!", "⚠️ Select a player first!")
                return
            end
            StartESP(target)
            Notify(
                "👁️ ESP مفعّل على: " .. target.DisplayName,
                "👁️ Target ESP ON: " .. target.DisplayName
            )
        else
            RemoveESP()
            Notify("❌ تم إيقاف ESP الهدف.", "❌ Target ESP OFF.")
        end
    end)
end
