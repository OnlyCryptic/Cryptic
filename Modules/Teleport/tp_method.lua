-- [[ Cryptic Hub - اختيار طريقة الانتقال ]]
return function(Tab, UI)
    -- القيمة الافتراضية
    _G.CrypticTPMethod = "انتقال فوري | Instant"
    
    Tab:AddDropdown("طريقة الانتقال | TP Method", {"انتقال فوري | Instant", "طيران سريع | Fly (Tween)"}, function(selected)
        _G.CrypticTPMethod = selected
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Cryptic Hub",
            Text = "تم التغيير إلى | Changed to:\n" .. selected,
            Duration = 3
        })
    end)
    Tab:AddLine()
end
