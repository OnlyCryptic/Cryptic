-- [[ Cryptic Hub - سكربت الإضاءة المطور ]]
-- المطور: Cryptic | التحديث: تحويل التحكم إلى شريط (Slider) + قيمة افتراضية 3

return function(Tab, UI)
    local Lighting = game:GetService("Lighting")
    
    -- حفظ الإعدادات الأصلية
    local orig = {
        Ambient = Lighting.Ambient,
        Outdoor = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        Shadows = Lighting.GlobalShadows
    }

    local function updateLighting(active, intensity)
        if active then
            -- تفعيل الإضاءة الكاملة بالشدة المختارة
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = intensity
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            -- إرجاع الإعدادات الأصلية
            Lighting.Ambient = orig.Ambient
            Lighting.OutdoorAmbient = orig.Outdoor
            Lighting.Brightness = orig.Brightness
            Lighting.ClockTime = orig.ClockTime
            Lighting.FogEnd = orig.FogEnd
            Lighting.GlobalShadows = orig.Shadows
        end
    end

    -- استخدام نظام التحكم الموحد (مثل الطيران والسرعة)
    -- القيمة الافتراضية 3، وأقصى شدة 10
    Tab:AddSpeedControl("إضاءة / lighting", function(active, value)
        updateLighting(active, value)
    end)
    
    -- ضبط القيمة التلقائية عند التحميل لتكون 3
    -- ملاحظة: مكتبة UI لديك ستحتاج لتمرير القيمة 3 افتراضياً
end
