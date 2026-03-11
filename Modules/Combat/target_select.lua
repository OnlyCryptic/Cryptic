-- [[ Cryptic Hub - نظام البحث عن لاعب (محدث) ]]
-- المطور: يامي (Yami) | الميزات: قائمة احترافية، بحث ذكي، تحديث تلقائي

return function(Tab, UI)
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 5, 
            })
        end)
    end

    -- استدعاء التصميم الاحترافي الجديد
    local PlayerSelector = Tab:AddPlayerSelector("تحديد لاعب الهدف / Target Player", "اكتب بداية اليوزر... / Type username start...", function(selectedValue)
        local targetPlayer = nil
        
        -- إذا كان الإدخال نص (بحث يدوي)
        if type(selectedValue) == "string" then
            local search = selectedValue:lower()
            for _, p in pairs(players:GetPlayers()) do
                if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                    targetPlayer = p
                    break 
                end
            end
        else
            -- إذا تم الاختيار من القائمة (كائن مباشر)
            targetPlayer = selectedValue
        end

        if targetPlayer then
            _G.ArwaTarget = targetPlayer
            PlayerSelector.SetText(targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")")
            Notify("🎯 تم تحديد الهدف: " .. targetPlayer.DisplayName, "Target selected: " .. targetPlayer.DisplayName)
        else
            _G.ArwaTarget = nil
            Notify("❌ لم يتم العثور على لاعب بهذا الاسم!", "Player not found!")
        end
    end)

    -- دالة لتحديث القائمة المنسدلة بأسماء الموجودين
    local function RefreshDropdown()
        local list = {}
        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp then table.insert(list, p) end
        end
        PlayerSelector.UpdateList(list)
    end

    -- تحميل القائمة أول مرة
    RefreshDropdown()

    -- تحديث تلقائي عند دخول أي لاعب جديد
    players.PlayerAdded:Connect(function(p)
        RefreshDropdown()
    end)

    -- التحقق وتحديث القائمة عند خروج أي لاعب
    players.PlayerRemoving:Connect(function(p)
        RefreshDropdown()
        
        -- لو اللاعب اللي خرج هو نفسه اللي محددينه
        if _G.ArwaTarget and _G.ArwaTarget == p then
            _G.ArwaTarget = nil
            PlayerSelector.Clear()
            Notify("⚠️ تنبيه: اللاعب المحدد غادر السيرفر!", "Alert: Target player left!")
        end
    end)
end
