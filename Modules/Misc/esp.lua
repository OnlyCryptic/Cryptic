-- [[ Cryptic Hub - ESP (Players) with names and distance ]]
return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local espObjects = {}
    local connections = {}

    local function Notify(text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = text,
                Duration = 4
            })
        end)
    end

    local function applyESP(char, plr)
        if plr == Players.LocalPlayer then return end

        pcall(function()
            if espObjects[plr] then
                if espObjects[plr].Highlight then espObjects[plr].Highlight:Destroy() end
                if espObjects[plr].Billboard then espObjects[plr].Billboard:Destroy() end
            end
            espObjects[plr] = {}

            if not char:FindFirstChild("CrypticESP_Highlight") then
                local h = Instance.new("Highlight", char)
                h.Name = "CrypticESP_Highlight"
                h.FillColor = Color3.fromRGB(0, 255, 150)
                h.OutlineColor = Color3.new(1, 1, 1)
                espObjects[plr].Highlight = h
            end

            local head = char:WaitForChild("Head", 2) or char:WaitForChild("HumanoidRootPart", 2)
            if head and not head:FindFirstChild("CrypticESP_Name") then
                local bgui = Instance.new("BillboardGui", head)
                bgui.Name = "CrypticESP_Name"
                bgui.AlwaysOnTop = true
                bgui.MaxDistance = math.huge
                bgui.ExtentsOffset = Vector3.new(0, 3, 0)
                bgui.Size = UDim2.new(0, 200, 0, 50)

                local textLabel = Instance.new("TextLabel", bgui)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = plr.DisplayName .. " [0]"
                textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                textLabel.TextSize = 14
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextStrokeTransparency = 0

                espObjects[plr].Billboard = bgui
                espObjects[plr].TextLabel = textLabel
            end
        end)
    end

    local function trackPlayer(plr)
        if plr.Character then applyESP(plr.Character, plr) end
        local charAddedConn = plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            applyESP(char, plr)
        end)
        table.insert(connections, charAddedConn)
    end

    Tab:AddToggle(T("misc.esp.label"), function(active)
        if active then
            for _, p in pairs(Players:GetPlayers()) do trackPlayer(p) end

            local playerAddedConn = Players.PlayerAdded:Connect(function(p) trackPlayer(p) end)
            table.insert(connections, playerAddedConn)

            local playerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
                if espObjects[plr] then
                    if espObjects[plr].Highlight then espObjects[plr].Highlight:Destroy() end
                    if espObjects[plr].Billboard then espObjects[plr].Billboard:Destroy() end
                    espObjects[plr] = nil
                end
            end)
            table.insert(connections, playerRemovingConn)

            local renderConn = RunService.RenderStepped:Connect(function()
                local lpChar = Players.LocalPlayer.Character
                local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")

                for plr, data in pairs(espObjects) do
                    if plr.Character and data.TextLabel then
                        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        if lpRoot and targetRoot then
                            local dist = math.floor((lpRoot.Position - targetRoot.Position).Magnitude)
                            data.TextLabel.Text = string.format("%s [%d]", plr.DisplayName, dist)
                        end
                    end
                end
            end)
            table.insert(connections, renderConn)

            Notify(T("misc.esp.on"))
        else
            for plr, data in pairs(espObjects) do
                if data.Highlight then data.Highlight:Destroy() end
                if data.Billboard then data.Billboard:Destroy() end
            end
            espObjects = {}

            for _, conn in pairs(connections) do
                if conn then conn:Disconnect() end
            end
            connections = {}
        end
    end)
end
