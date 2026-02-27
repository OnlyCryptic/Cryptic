-- ملف ميزة كشف اللاعبين (ESP)
return function(Tab, UI)
    local highlights = {}
    local espActive = false

    -- وظيفة إضافة التوهج للاعب
    local function applyESP(plr)
        if plr == game.Players.LocalPlayer then return end
        
        local function highlight()
            local char = plr.Character or plr.CharacterAdded:Wait()
            if not char:FindFirstChild("CrypticESP") then
                local h = Instance.new("Highlight")
                h.Name = "CrypticESP"
                h.FillColor = Color3.fromRGB(0, 255, 150) -- لون النيون الأخضر
                h.OutlineColor = Color3.new(1, 1, 1)
                h.FillTransparency = 0.5
                h.Parent = char
                highlights[plr] = h
            end
        end
        highlight()
        plr.CharacterAdded:Connect(highlight)
    end

    -- استخدام نظام التحكم المطور (Toggle)
    Tab:AddSpeedControl("كشف اللاعبين", function(active)
        espActive = active
        if espActive then
            for _, p in pairs(game.Players:GetPlayers()) do
                applyESP(p)
            end
            UI:Notify("تم تفعيل كشف اللاعبين (ESP)")
        else
            -- إزالة الكشف عند الإيقاف
            for plr, h in pairs(highlights) do
                if h then h:Destroy() end
            end
            highlights = {}
            UI:Notify("تم إيقاف الكشف")
        end
    end)
end
