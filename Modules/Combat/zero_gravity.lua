return function(Tab, UI)
    local isZeroGravity = false
    -- حفظ قيمة الجاذبية الأصلية للعبة (غالباً تكون 196.2)
    local OriginalGravity = workspace.Gravity

    Tab:AddToggle("إزالة الجاذبية 🚀", function(state)
        isZeroGravity = state
        
        if isZeroGravity then
            -- جعل الجاذبية صفر (انعدام الجاذبية)
            workspace.Gravity = 0 
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "تم انعدام الجاذبية! اقفز لتطير 🌌",
                Duration = 3
            })
        else
            -- إرجاع الجاذبية لوضعها الطبيعي
            workspace.Gravity = OriginalGravity 
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "عادت الجاذبية لطبيعتها 🌍",
                Duration = 3
            })
        end
    end)
end
