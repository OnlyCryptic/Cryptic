-- [[ Cryptic Hub - اختيار طريقة الانتقال ]]
return function(Tab, UI)
    -- القيمة الافتراضية إذا ما اختار اللاعب شيء
    _G.CrypticTPMethod = "انتقال فوري (Instant)"
    
    Tab:AddDropdown("طريقة الانتقال", {"انتقال فوري (Instant)", "طيران سريع (Fly/Tween)"}, function(selected)
        _G.CrypticTPMethod = selected
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Cryptic Hub",
            Text = "تم التغيير إلى: " .. selected,
            Duration = 3
        })
    end)
    Tab:AddLine()
end
