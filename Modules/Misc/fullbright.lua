-- [[ Cryptic Hub - سكربت الإضاءة المطور ]]
-- المطور: Cryptic | التحديث: ضبط القيمة الافتراضية على 3 لمنع السطوع الزائد

return function(Tab, UI)
    local Lighting = game:GetService("Lighting")
    
    -- حفظ الإعدادات الأصلية للماب عشان نقدر نرجع لها عند الإيقاف
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
            -- تفعيل الإضاءة الكاملة بالشدة التي يختارها المستخدم
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = intensity
            Lighting.ClockTime = 14 -- جعل الوقت ظهراً لضمان أقصى سطوع
            Lighting.FogEnd = 100000 -- إزالة الضباب
            Lighting.GlobalShadows = false -- إزالة الظلال المزعجة
        else
            -- إرجاع الإعدادات الأصلية للماب بدقة
            Lighting.Ambient = orig.Ambient
            Lighting.OutdoorAmbient = orig.Outdoor
            Lighting.Brightness = orig.Brightness
            Lighting.ClockTime = orig.ClockTime
            Lighting.FogEnd = orig.FogEnd
            Lighting.GlobalShadows = orig.Shadows
        end
    end

    -- [[ التعديل الأهم ]]
    -- أضفنا الرقم 3 في نهاية الدالة ليقرأه محرك الواجهة V4.6 كقيمة بداية تلقائية
    Tab:AddSpeedControl("إضاءة / lighting", function(active, value)
        updateLighting(active, value)
    end, 3) 
end
