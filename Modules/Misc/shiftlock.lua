return function(Tab, UI)
    local lp = game:GetService("Players").LocalPlayer
    local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
    
    Tab:AddToggle("🔒 تشغيل الشيفت لوك)", function(active)
        if hum then
            hum.CameraOffset = active and Vector3.new(1.7, 0.5, 0) or Vector3.new(0, 0, 0)
            UI:Notify(active and "تم تفعيل الشيفت لوك" or "تم الإيقاف")
        end
    end)
end
