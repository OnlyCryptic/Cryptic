-- [[ Cryptic Hub - Lag Reduce ]]
-- تخفيف اللاق وتحسين الأداء — يعمل على جميع الأجهزة والمتصفحات
-- Localized via i18n. Key: settings.lag_reduce.*

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end

    local Lighting   = game:GetService("Lighting")
    local StarterGui = game:GetService("StarterGui")
    local Terrain    = workspace.Terrain

    local PARTICLE_TYPES = {
        "ParticleEmitter", "Fire", "Smoke",
        "Sparkles", "Trail", "Beam"
    }

    -- حفظ القيم الأصلية مرة واحدة عند التحميل
    local orig = {}
    pcall(function()
        orig.Technology       = Lighting.Technology
        orig.GlobalShadows    = Lighting.GlobalShadows
        orig.FogEnd           = Lighting.FogEnd
        orig.FogStart         = Lighting.FogStart
        orig.Ambient          = Lighting.Ambient
        orig.OutdoorAmbient   = Lighting.OutdoorAmbient
        orig.Brightness       = Lighting.Brightness
        orig.ClockTime        = Lighting.ClockTime
        orig.Decoration       = Terrain.Decoration
        orig.WaterWaveSize    = Terrain.WaterWaveSize
        orig.WaterWaveSpeed   = Terrain.WaterWaveSpeed
        orig.WaterReflectance = Terrain.WaterReflectance
        orig.WaterTransparency= Terrain.WaterTransparency
    end)

    -- قائمة الاتصالات لفصلها عند الإيقاف
    local connections = {}

    local function disconnectAll()
        for _, c in pairs(connections) do
            pcall(function() c:Disconnect() end)
        end
        connections = {}
    end

    local function isParticle(obj)
        for _, cls in pairs(PARTICLE_TYPES) do
            if obj:IsA(cls) then return true end
        end
        return false
    end

    local function applyToDescendants(root, fn)
        pcall(function()
            for _, v in pairs(root:GetDescendants()) do
                pcall(fn, v)
            end
        end)
    end

    -- ------------------------------------------------------------------ --
    local function enableLagReduce()

        -- 1. أقل جودة رندر ممكنة
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)

        -- 2. وضع الإضاءة الأخف (أكبر فرق في الأداء)
        pcall(function()
            Lighting.Technology = Enum.Technology.Compatibility
        end)

        -- 3. إيقاف الظلال العالمية
        pcall(function()
            Lighting.GlobalShadows = false
        end)

        -- 4. إيقاف تظليل جميع الأجزاء (حالية + جديدة)
        applyToDescendants(workspace, function(v)
            if v:IsA("BasePart") then v.CastShadow = false end
        end)
        table.insert(connections, workspace.DescendantAdded:Connect(function(v)
            if v:IsA("BasePart") then
                pcall(function() v.CastShadow = false end)
            end
        end))

        -- 5. إيقاف الجسيمات والتأثيرات (حالية + جديدة)
        applyToDescendants(workspace, function(v)
            if isParticle(v) then v.Enabled = false end
        end)
        table.insert(connections, workspace.DescendantAdded:Connect(function(v)
            if isParticle(v) then
                pcall(function() v.Enabled = false end)
            end
        end))

        -- 6. إيقاف تأثيرات الإضاءة (PostEffect, Atmosphere, Clouds, Sky)
        pcall(function()
            for _, v in pairs(Lighting:GetChildren()) do
                local ok, isEffect = pcall(function()
                    return v:IsA("PostEffect")
                        or v:IsA("Atmosphere")
                        or v:IsA("Clouds")
                        or v:IsA("Sky")
                end)
                if ok and isEffect then
                    pcall(function() v.Enabled = false end)
                end
            end
        end)

        -- 7. إزالة الضباب وتحسين الإضاءة
        pcall(function()
            Lighting.FogEnd         = 9e9
            Lighting.FogStart       = 9e9
            Lighting.Brightness     = 3
            Lighting.ClockTime      = 14
            Lighting.Ambient        = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        end)

        -- 8. تحسين الترين
        pcall(function()
            Terrain.Decoration         = false
            Terrain.WaterWaveSize      = 0
            Terrain.WaterWaveSpeed     = 0
            Terrain.WaterReflectance   = 0
            Terrain.WaterTransparency  = 0
        end)

        -- 9. تقليل مدى الأصوات (حالية + جديدة)
        applyToDescendants(workspace, function(v)
            if v:IsA("Sound") and v.MaxDistance > 40 then
                v.MaxDistance = 40
            end
        end)
        table.insert(connections, workspace.DescendantAdded:Connect(function(v)
            if v:IsA("Sound") then
                pcall(function()
                    if v.MaxDistance > 40 then v.MaxDistance = 40 end
                end)
            end
        end))

        -- 10. فك حد الفريمات
        pcall(function()
            if setfpscap then setfpscap(9999) end
        end)
        pcall(function()
            settings().Rendering.FrameRateManager = Enum.FramerateManagerMode.Unbounded
        end)

        -- إشعار
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "⚡ " .. T("settings.lag_reduce.label"),
                Text  = T("settings.lag_reduce.on"),
                Duration = 3,
            })
        end)
    end

    -- ------------------------------------------------------------------ --
    local function disableLagReduce()

        disconnectAll()

        -- استعادة جودة الرندر
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)

        -- استعادة تقنية الإضاءة
        pcall(function()
            Lighting.Technology    = orig.Technology    or Enum.Technology.Future
            Lighting.GlobalShadows = orig.GlobalShadows ~= nil and orig.GlobalShadows or true
        end)

        -- إعادة تأثيرات الإضاءة
        pcall(function()
            for _, v in pairs(Lighting:GetChildren()) do
                local ok, isEffect = pcall(function()
                    return v:IsA("PostEffect")
                        or v:IsA("Atmosphere")
                        or v:IsA("Clouds")
                        or v:IsA("Sky")
                end)
                if ok and isEffect then
                    pcall(function() v.Enabled = true end)
                end
            end
        end)

        -- استعادة الضباب والإضاءة
        pcall(function()
            Lighting.FogEnd         = orig.FogEnd         or 1e6
            Lighting.FogStart       = orig.FogStart       or 0
            Lighting.Brightness     = orig.Brightness     or 1
            Lighting.ClockTime      = orig.ClockTime      or 14
            Lighting.Ambient        = orig.Ambient        or Color3.fromRGB(127,127,127)
            Lighting.OutdoorAmbient = orig.OutdoorAmbient or Color3.fromRGB(127,127,127)
        end)

        -- استعادة الترين
        pcall(function()
            Terrain.Decoration         = orig.Decoration        ~= nil and orig.Decoration        or true
            Terrain.WaterWaveSize      = orig.WaterWaveSize     or 0.5
            Terrain.WaterWaveSpeed     = orig.WaterWaveSpeed    or 0.5
            Terrain.WaterReflectance   = orig.WaterReflectance  or 0
            Terrain.WaterTransparency  = orig.WaterTransparency or 0
        end)

        -- استعادة إعدادات الأصوات — بما أن ما عندنا القيم الأصلية نرجعها للافتراضي
        applyToDescendants(workspace, function(v)
            if v:IsA("Sound") and v.MaxDistance <= 40 then
                v.MaxDistance = 10000
            end
        end)

        -- استعادة حد الفريمات
        pcall(function()
            if setfpscap then setfpscap(60) end
        end)
        pcall(function()
            settings().Rendering.FrameRateManager = Enum.FramerateManagerMode.Automatic
        end)

        -- إشعار
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "⚡ " .. T("settings.lag_reduce.label"),
                Text  = T("settings.lag_reduce.off"),
                Duration = 3,
            })
        end)
    end

    -- ------------------------------------------------------------------ --
    Tab:AddToggle(T("settings.lag_reduce.label"), function(active)
        if active then
            enableLagReduce()
        else
            disableLagReduce()
        end
    end)
end
