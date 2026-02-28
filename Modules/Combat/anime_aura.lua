-- [[ Arwa Hub - خدعة هالة الأنمي (Anime Aura) ]]
-- المطور: Arwa | الميزات: هالة متوهجة، ألوان قوس قزح، جزيئات طاقة

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    
    local isAuraEnabled = false
    local auraParts = {} -- لتخزين أجزاء الهالة وتنظيفها

    -- وظيفة إنشاء الهالة والجزيئات
    local function createAura(char)
        if not char then return end
        
        -- تنظيف أي هالة قديمة لتجنب التكرار
        for _, part in pairs(auraParts) do pcall(function() part:Destroy() end) end
        auraParts = {}

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- 1. إنشاء تأثير التوهج الأساسي (Glow)
        local glow = Instance.new("Attachment")
        glow.Name = "ArwaGlowAttachment"
        glow.Parent = root
        table.insert(auraParts, glow)

        local light = Instance.new("PointLight")
        light.Name = "ArwaAuraLight"
        light.Brightness = 2 -- قوة الإضاءة
        light.Range = 10 -- مدى الضوء
        light.Shadows = false
        light.Parent = glow
        table.insert(auraParts, light)

        -- 2. إنشاء الجزيئات المتطايرة (Particles)
        local particles = Instance.new("ParticleEmitter")
        particles.Name = "ArwaAnimeParticles"
        particles.Texture = "rbxassetid://241381913" -- قوام ناري شفاف مناسب للأنمي
        particles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 1.5), NumberSequenceKeypoint.new(1, 0)})
        particles.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
        particles.Lifetime = NumberRange.new(1, 2)
        particles.Speed = NumberRange.new(2, 5)
        particles.Rate = 50 -- عدد الجزيئات في الثانية
        particles.SpreadAngle = Vector2.new(180, 180)
        particles.Parent = glow
        table.insert(auraParts, particles)

        -- 3. حلقة تغيير الألوان (قوس قزح)
        task.spawn(function()
            local hue = 0
            while isAuraEnabled and char and char.Parent do
                hue = hue + 0.01
                if hue > 1 then hue = 0 end
                
                local color = Color3.fromHSV(hue, 1, 1)
                pcall(function()
                    light.Color = color
                    particles.Color = ColorSequence.new(color)
                end)
                task.wait(0.05) -- سرعة تغيير الألوان
            end
        end)
    end

    Tab:AddToggle("✨ تفعيل هالة الأنمي (Aura)", function(active)
        isAuraEnabled = active
        if active then
            if lp.Character then createAura(lp.Character) end
            UI:Notify("✨ تم تفعيل هالة الأنمي القتالية!")
        else
            -- تنظيف الهالة عند الإيقاف
            for _, part in pairs(auraParts) do pcall(function() part:Destroy() end) end
            auraParts = {}
            UI:Notify("❌ تم إيقاف الهالة")
        end
    end)

    -- إعادة تفعيل الهالة تلقائياً عند الإحياء (Respawn)
    lp.CharacterAdded:Connect(function(char)
        if isAuraEnabled then
            task.wait(1) -- انتظار تحميل الشخصية
            createAura(char)
        end
    end)
end
