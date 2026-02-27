-- [[ Cryptic Hub - المراقبة ]]
return function(Tab, UI)
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    local selectedPlayer = nil
    local isSpectating = false
    local SpectateToggle

    local InputField = Tab:AddInput("البحث عن لاعب", "اكتب بداية اليوزر وأغلق الكيبورد...", function(txt) end)

    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then selectedPlayer = nil; return end

        local bestMatch = nil
        local search = txt:lower()

        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p; break 
            end
        end

        if bestMatch then
            selectedPlayer = bestMatch
            InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
        else
            selectedPlayer = nil
        end
    end)

    SpectateToggle = Tab:AddToggle("تشغيل وضع المراقبة", function(active)
        isSpectating = active
        if active and selectedPlayer then camera.CameraSubject = selectedPlayer.Character.Humanoid
        else camera.CameraSubject = lp.Character.Humanoid end
    end)

    Tab:AddButton("انتقال إلى اللاعب المختار", function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then 
            lp.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0) 
        end
    end)

    task.spawn(function()
        while task.wait(0.5) do
            if isSpectating and selectedPlayer then camera.CameraSubject = selectedPlayer.Character.Humanoid end
        end
    end)
end
