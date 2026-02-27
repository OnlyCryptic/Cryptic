-- ملف ميزة السرعة (speed.lua)
-- هذا الملف يتم استدعاؤه بواسطة main.lua

return function(Tab, UI)
    -- إضافة زر لزيادة السرعة
    Tab:AddButton("تفعيل سرعة البرق (100)", function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 100
            UI:Notify("تم تفعيل السرعة بنجاح!")
        end
    end)

    -- إضافة زر لإعادة السرعة للطبيعي
    Tab:AddButton("إعادة السرعة الطبيعية (16)", function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            UI:Notify("تمت العودة للوضع الطبيعي")
        end
    end)
end
