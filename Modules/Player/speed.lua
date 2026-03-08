-- [[ Cryptic Hub - السرعة المطورة / Advanced WalkSpeed ]]
-- المطور: يامي (Yami) | التحديث: ضبط السرعة الافتراضية على 50 لتتوافق مع المحرك V4.6 / Update: Default speed set to 50 for V4.6 engine

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    
    -- أضفنا الرقم 50 في نهاية الدالة ليكون القيمة الافتراضية في الخانة / Added 50 as the default value in the input field
    Tab:AddSpeedControl("سرعة المشي / WalkSpeed", function(active, value)
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        
        if hum then
            -- إذا تم تفعيل الزر، يأخذ القيمة المكتوبة، وإذا أطفي يرجع للسرعة الطبيعية (16)
            -- If enabled, uses the inputted value; if disabled, returns to default speed (16)
            hum.WalkSpeed = active and value or 16 
        end
    end, 50)
end
