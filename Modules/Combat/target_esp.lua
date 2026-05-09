-- [[ Cryptic Hub - Target ESP ]]

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local isEspActive = false
    local highlight = nil
    local boxLine = nil
    local distLabel = nil
    local connection = nil

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = text,
                Duration = 3
            })
        end)
    end

    local function CleanupEsp()
        if connection then connection:Disconnect() connection = nil end
        if highlight then highlight:Destroy() highlight = nil end
        if boxLine then boxLine:Destroy() boxLine = nil end
        if distLabel then distLabel:Destroy() distLabel = nil end
    end

    Tab:AddToggle(T("combat.esp.label"), function(active)
        isEspActive = active
        CleanupEsp()

        if not active then return end

        local target = _G.ArwaTarget
        if not target or not target.Character then
            Notify(T("combat.common.no_target"))
            isEspActive = false
            return
        end

        local function ApplyEsp(targetChar)
            highlight = Instance.new("Highlight")
            highlight.Adornee = targetChar
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = targetChar

            local head = targetChar:FindFirstChild("Head")
            if head then
                distLabel = Instance.new("BillboardGui")
                distLabel.Adornee = head
                distLabel.Size = UDim2.new(0, 100, 0, 30)
                distLabel.StudsOffset = Vector3.new(0, 2.5, 0)
                distLabel.AlwaysOnTop = true
                distLabel.Parent = head

                local tl = Instance.new("TextLabel", distLabel)
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = ""
                tl.TextScaled = true
                tl.Font = Enum.Font.GothamBold
                tl.TextColor3 = Color3.fromRGB(255, 80, 80)
                tl.TextStrokeTransparency = 0
            end
        end

        ApplyEsp(target.Character)

        connection = RunService.RenderStepped:Connect(function()
            if not isEspActive then return end
            local tgt = _G.ArwaTarget
            if not tgt or not tgt.Character or not lp.Character then return end

            local myRoot = lp.Character:FindFirstChild("HumanoidRootPart")
            local tRoot = tgt.Character:FindFirstChild("HumanoidRootPart")
            if myRoot and tRoot and distLabel then
                local dist = math.floor((myRoot.Position - tRoot.Position).Magnitude)
                local lab = distLabel:FindFirstChildOfClass("TextLabel")
                if lab then lab.Text = dist .. " m" end
            end
        end)

        Notify(string.format(T("combat.esp.on_fmt"), target.DisplayName))

        target.CharacterAdded:Connect(function(char)
            if isEspActive then
                task.wait(1)
                CleanupEsp()
                ApplyEsp(char)
            end
        end)
    end)
end
