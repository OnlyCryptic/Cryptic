return function(Tab, UI)
    local players = game:GetService("Players")
    
    Tab:AddInput("🎯 اختر الهدف", "اكتب اسم اللاعب هنا...", function(txt)
        local search = txt:lower()
        for _, p in pairs(players:GetPlayers()) do
            if p ~= players.LocalPlayer and string.sub(p.Name:lower(), 1, #search) == search then
                _G.ArwaTarget = p -- تخزين اللاعب في متغير عام ليستخدمه الكل
                UI:Notify("✅ تم تحديد: " .. p.DisplayName)
                return
            end
        end
        _G.ArwaTarget = nil
        UI:Notify("❌ لم يتم العثور على اللاعب")
    end)
end
