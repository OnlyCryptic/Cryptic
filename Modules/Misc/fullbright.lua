-- [[ Cryptic Hub - سكربت الإضاءة المطور / Advanced Lighting Script ]]
-- المطور: يامي (Yami) | التحديث: إشعار تفعيل فقط + ترجمة مزدوجة / Update: Activation notify only + Dual language

return function(Tab, UI)
    local Lighting = game:GetService("Lighting")
    local StarterGui = game:GetService("StarterGui")
    
    -- حفظ الإعدادات الأصلية للماب / Save original map settings
    local orig = {
        Ambient = Lighting.Ambient,
        Outdoor = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        Shadows = Lighting.GlobalShadows
    }

    -- دالة إرسال الإشعارات المزدوجة / Dual notification function
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 4
            })
        end)
    end

    local function updateLighting(active, intensity)
        if active then
            -- تفعيل الإضاءة الكاملة / Enable Full Bright
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = intensity
            Lighting.ClockTime = 14 
            Lighting.FogEnd = 100000 
            Lighting.GlobalShadows = false 
        else
            -- إرجاع الإعدادات الأصلية بصمت / Restore original settings silently
            Lighting.Ambient = orig.Ambient
            Lighting.OutdoorAmbient = orig.Outdoor
            Lighting.Brightness = orig.Brightness
            Lighting.ClockTime = orig.ClockTime
            Lighting.FogEnd = orig.FogEnd
            Lighting.GlobalShadows = orig.Shadows
        end
    end

    -- إضافة التحكم للواجهة بقيمة افتراضية (3) / Add control to UI with default value (3)
    Tab:AddSpeedControl("إضاءة / Lighting", function(active, value)
        updateLighting(active, value)
        
        -- إشعار التفعيل المزدوج فقط / Activation notify only
        if active then
            Notify("✨ تم تفعيل الإضاءة الكاملة!", "✨ Full Bright Activated!")
        end
    end, 3) 
end
