-- [[ Cryptic Hub - السرعة المطورة ]]
-- المطور: Cryptic | التحديث: ضبط السرعة الافتراضية على 50 لتتوافق مع المحرك V4.6

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    
    -- أضفنا الرقم 50 في نهاية الدالة ليكون القيمة الافتراضية في الخانة
    Tab:AddSpeedControl("سرعة المشي / WalkSpeed", function(active, value)
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        
        if hum then
            -- إذا تم تفعيل الزر، يأخذ القيمة المكتوبة، وإذا أطفي يرجع للسرعة الطبيعية (16)
            hum.WalkSpeed = active and value or 16 
        end
    end, 50)
end
