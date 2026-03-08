-- [[ Cryptic Hub - نظام البحث عن لاعب ]]
-- المطور: يامي (Yami) | الميزات: بحث ذكي، إشعارات مزدوجة (عربي/إنجليزي)

return function(Tab, UI)
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    
    -- دالة إشعارات روبلوكس الرسمية (مزدوجة اللغة)
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 10, 
            })
        end)
    end

    -- خانة البحث مع نص توضيحي باللغتين
    local InputField = Tab:AddInput("تحديد لاعب الهدف / Target Player", "اكتب بداية اليوزر... / Type username start...", function(txt) end)

    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then 
            _G.ArwaTarget = nil
            return 
        end

        local bestMatch = nil
        local search = txt:lower()

        for _, p in pairs(players:GetPlayers()) do
            -- نظام البحث الذكي عن طريق بداية الاسم (اليوزر)
            if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p
                break 
            end
        end

        if bestMatch then
            _G.ArwaTarget = bestMatch
            -- تحديث نص الخانة ليظهر الاسم الكامل واليوزر
            InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
            
            -- إشعار النجاح باللغتين
            Notify(
                "🎯 تم تحديد الهدف: " .. bestMatch.DisplayName,
                "Target selected: " .. bestMatch.DisplayName
            )
        else
            _G.ArwaTarget = nil
            
            -- إشعار الفشل باللغتين
            Notify(
                "❌ لم يتم العثور على لاعب بهذا الاسم!",
                "Player not found!"
            )
        end
    end)
end
