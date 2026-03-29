-- [[ Cryptic Hub - كشف الهدف فقط (Target ESP) ]]

return function(Tab, UI)
    local Players    = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp         = Players.LocalPlayer

    local espData   = {}   -- { Highlight, Billboard, TextLabel }
    local renderConn = nil

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text  = ar .. "\n" .. en,
                Duration = 4,
            })
        end)
    end

    local function RemoveESP()
        if espData.Highlight then
            pcall(function() espData.Highlight:Destroy() end)
        end
        if espData.Billboard then
            pcall(function() espData.Billboard:Destroy() end)
        end
        espData = {}
        if renderConn then
            renderConn:Disconnect()
            renderConn = nil
        end
    end

    local function ApplyESP(plr)
        RemoveESP()

        local char = plr and plr.Character
        if not char then return end

        pcall(function()
            -- Highlight
            if not char:FindFirstChild("CrypticTargetESP_H") then
                local h = Instance.new("Highlight", char)
                h.Name         = "CrypticTargetESP_H"
                h.FillColor    = Color3.fromRGB(255, 50, 50)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.FillTransparency    = 0.35
                h.OutlineTransparency = 0
                espData.Highlight = h
            end

            -- BillboardGui (اسم + مسافة)
            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if head and not head:FindFirstChild("CrypticTargetESP_BB") then
                local bb = Instance.new("BillboardGui", head)
                bb.Name         = "CrypticTargetESP_BB"
                bb.AlwaysOnTop  = true
                bb.MaxDistance  = math.huge
                bb.ExtentsOffset = Vector3.new(0, 3.5, 0)
                bb.Size         = UDim2.new(0, 220, 0, 55)

                local lbl = Instance.new("TextLabel", bb)
                lbl.Size                 = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text                 = "🎯 " .. plr.DisplayName .. " [?]"
                lbl.TextColor3           = Color3.fromRGB(255, 80, 80)
                lbl.TextSize             = 15
                lbl.Font                 = Enum.Font.GothamBold
                lbl.TextStrokeTransparency = 0
                lbl.TextStrokeColor3     = Color3.new(0, 0, 0)

                espData.Billboard  = bb
                espData.TextLabel  = lbl
            end
        end)

        -- تحديث المسافة في كل فريم
        renderConn = RunService.RenderStepped:Connect(function()
            local target = _G.ArwaTarget
            if not target or not target.Character then return end
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            local lpChar = lp.Character
            local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")

            if espData.TextLabel and tRoot and lpRoot then
                local dist = math.floor((lpRoot.Position - tRoot.Position).Magnitude)
                espData.TextLabel.Text = "🎯 " .. target.DisplayName .. " [" .. dist .. "m]"
            end

            -- تنظيف إذا تغيّر الهدف أو خرج
            if not espData.Highlight or not espData.Highlight.Parent then
                RemoveESP()
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
            ApplyESP(target)
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
