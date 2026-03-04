-- [[ Cryptic Hub - نظام البحث عن لاعب ]]
-- المطور: يامي (Yami) | الميزات: بحث ذكي، إشعارات رسمية 25 ثانية

return function(Tab, UI)
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    
    -- دالة إشعارات روبلوكس الرسمية (مدة 25 ثانية)
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 10, 
            })
        end)
    end

    -- خانة البحث
    local InputField = Tab:AddInput("تحديد لاعب الهدف / target player", "اكتب بداية اليوزر وأغلق الكيبورد...", function(txt) end)

    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then 
            _G.ArwaTarget = nil
            return 
        end

        local bestMatch = nil
        local search = txt:lower()

        for _, p in pairs(players:GetPlayers()) do
            -- نظام البحث الذكي عن طريق بداية الاسم
            if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p
                break 
            end
        end

        if bestMatch then
            _G.ArwaTarget = bestMatch
            -- تحديث نص الخانة ليظهر الاسم الكامل واليوزر
            InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
            SendRobloxNotification("Cryptic Hub", "🎯 تم تحديد الهدف بنجاح: " .. bestMatch.DisplayName)
        else
            _G.ArwaTarget = nil
            SendRobloxNotification("Cryptic Hub", "❌ لم يتم العثور على لاعب بهذا الاسم!")
        end
    end)
end
