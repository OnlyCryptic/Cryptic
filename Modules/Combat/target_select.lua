return function(Tab, UI)
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    -- خانة البحث (نفس نظام الكود القديم)
    local InputField = Tab:AddInput("البحث عن لاعب", "اكتب بداية اليوزر وأغلق الكيبورد...", function(txt) end)

    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then 
            _G.ArwaTarget = nil
            return 
        end

        local bestMatch = nil
        local search = txt:lower()

        for _, p in pairs(players:GetPlayers()) do
            -- استخدام string.sub للبحث الذكي كما في الكود السابق
            if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p
                break 
            end
        end

        if bestMatch then
            _G.ArwaTarget = bestMatch
            -- تحديث نص الخانة ليظهر الاسم كاملاً كما طلبتِ
            InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
            UI:Notify("🎯 تم تحديد الهدف: " .. bestMatch.DisplayName)
        else
            _G.ArwaTarget = nil
            UI:Notify("❌ لم يتم العثور على لاعب")
        end
    end)
end
