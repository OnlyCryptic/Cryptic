return function(Tab, UI)
    local Lighting = game:GetService("Lighting")
    local isFullBright = false
    
    -- حفظ إعدادات الإضاءة الأصلية للماب عشان نقدر نرجعها
    local origAmbient = Lighting.Ambient
    local origOutdoor = Lighting.OutdoorAmbient
    local origBrightness = Lighting.Brightness
    local origClockTime = Lighting.ClockTime
    local origFogEnd = Lighting.FogEnd
    local origShadows = Lighting.GlobalShadows

    -- 1. زر تفعيل الصباح (إضاءة كاملة وإلغاء الظلام)
    Tab:AddToggle("إضاءة كاملة (صباح) ☀️", function(state)
        isFullBright = state
        
        if isFullBright then
            -- تحديث الإعدادات الأصلية في حال تغيرت قبل التفعيل
            origAmbient = Lighting.Ambient
            origOutdoor = Lighting.OutdoorAmbient
            origBrightness = Lighting.Brightness
            origClockTime = Lighting.ClockTime
            origFogEnd = Lighting.FogEnd
            origShadows = Lighting.GlobalShadows
            
            -- تحويل الماب لصباح مشرق وإلغاء الظلال
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 3 -- إضاءة ممتازة
            Lighting.ClockTime = 14 -- الساعة 2 الظهر
            Lighting.FogEnd = 100000 -- إلغاء الضباب
            Lighting.GlobalShadows = false -- إلغاء الظلال اللي تسبب ظلام في الغرف
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "شرقت الشمس! ☀️ كل الغرف المظلمة صارت منورة",
                Duration = 4
            })
        else
            -- إرجاع الإضاءة الأصلية للماب
            Lighting.Ambient = origAmbient
            Lighting.OutdoorAmbient = origOutdoor
            Lighting.Brightness = origBrightness
            Lighting.ClockTime = origClockTime
            Lighting.FogEnd = origFogEnd
            Lighting.GlobalShadows = origShadows
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "عادت إضاءة الماب لطبيعتها 🌙",
                Duration = 3
            })
        end
    end)

    -- 2. مربع تعديل قوة الإضاءة يدوياً
    Tab:AddInput("تعديل قوة السطوع 💡", "اكتب رقم (مثال: 2 أو 5)", function(text)
        local value = tonumber(text)
        
        if value then
            Lighting.Brightness = value
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.GlobalShadows = false
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "تم تغيير قوة الإضاءة إلى: " .. tostring(value),
                Duration = 3
            })
        else
            -- إذا أدخل أحرف بدل الأرقام
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "يرجى كتابة رقم صحيح!",
                Duration = 2
            })
        end
    end)
end
