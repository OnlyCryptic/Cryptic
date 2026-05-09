-- [[ Cryptic Hub - Advanced Lighting Script ]]
return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local Lighting = game:GetService("Lighting")
    local StarterGui = game:GetService("StarterGui")

    local orig = {
        Ambient = Lighting.Ambient,
        Outdoor = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        Shadows = Lighting.GlobalShadows
    }

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = text,
                Duration = 4
            })
        end)
    end

    local function updateLighting(active, intensity)
        if active then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = intensity
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = orig.Ambient
            Lighting.OutdoorAmbient = orig.Outdoor
            Lighting.Brightness = orig.Brightness
            Lighting.ClockTime = orig.ClockTime
            Lighting.FogEnd = orig.FogEnd
            Lighting.GlobalShadows = orig.Shadows
        end
    end

    Tab:AddSpeedControl(T("misc.fullbright.label"), function(active, value)
        updateLighting(active, value)
        if active then
            Notify(T("misc.fullbright.on"))
        end
    end, 3)
end
