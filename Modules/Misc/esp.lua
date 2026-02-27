return function(Tab, UI)
    local highlights = {}

    local function applyESP(plr)
        if plr == game.Players.LocalPlayer then return end
        local char = plr.Character or plr.CharacterAdded:Wait()
        if not char:FindFirstChild("CrypticESP") then
            local h = Instance.new("Highlight", char)
            h.Name = "CrypticESP"
            h.FillColor = Color3.fromRGB(0, 255, 150)
            highlights[plr] = h
        end
    end

    -- استخدام AddToggle هنا لإزالة الأزرار الزائدة (+ و -)
    Tab:AddToggle("كشف اللاعبين (ESP)", function(active)
        if active then
            for _, p in pairs(game.Players:GetPlayers()) do applyESP(p) end
            UI:Notify("تم تفعيل الكشف")
        else
            for _, h in pairs(highlights) do if h then h:Destroy() end end
            highlights = {}
            UI:Notify("تم إيقاف الكشف")
        end
    end)
end
