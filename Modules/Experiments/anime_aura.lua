-- [[ Arwa Hub - ميزة هالة الأنمي المطورة ]]
-- المطور: Arwa | المظهر: إعصار طاقة ملون

return function(Tab, UI)
    local lp = game.Players.LocalPlayer
    local isAuraEnabled = false
    local auraObjects = {}

    -- وظيفة تنظيف الهالة القديمة
    local function cleanAura()
        for _, obj in pairs(auraObjects) do
            if obj then pcall(function() obj:Destroy() end) end
        end
        auraObjects = {}
    end

    -- وظيفة إنشاء تأثيرات الهالة
    local function createAuraEffect(char)
        cleanAura()
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local root = char.HumanoidRootPart
        local att = Instance.new("Attachment")
        att.Name = "ArwaAuraEffect"
        att.Parent = root
        table.insert(auraObjects, att)

        -- 1. إضافة الإضاءة المتوهجة
        local light = Instance.new("PointLight")
        light.Brightness = 3
        light.Range = 12
        light.Parent = att

        -- 2. إضافة جزيئات الطاقة (Particles)
        local particles = Instance.new("ParticleEmitter")
        particles.Texture = "rbxassetid://241381913" -- قوام طاقة الأنمي
        particles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 2), NumberSequenceKeypoint.new(1, 0)})
        particles.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
        particles.Lifetime = NumberRange.new(0.8, 1.5)
        particles.Speed = NumberRange.new(3, 6)
        particles.Rate = 60
        particles.SpreadAngle = Vector2.new(360, 360)
        particles.Parent = att

        -- 3. حلقة تغيير الألوان (قوس قزح) لتناسب ذوق أروى
        task.spawn(function()
            local hue = 0
            while isAuraEnabled and char and char.Parent do
                hue = (hue + 1/360) % 1
                local color = Color3.fromHSV(hue, 0.8, 1)
                pcall(function()
                    light.Color = color
                    particles.Color = ColorSequence.new(color)
                end)
                task.wait(0.03)
            end
        end)
    end

    -- إضافة الزر في قسم "خدع"
    Tab:AddToggle("✨ تفعيل هالة الأنمي (Aura)", function(active)
        isAuraEnabled = active
        if active then
            createAuraEffect(lp.Character)
            UI:Notify("✨ تم تفعيل هالة الطاقة! أنتِ الآن بطلة أنمي")
        else
            cleanAura()
            UI:Notify("❌ تم إيقاف الهالة")
        end
    end)

    -- إعادة التفعيل عند العودة للحياة
    lp.CharacterAdded:Connect(function(char)
        if isAuraEnabled then
            task.wait(1)
            createAuraEffect(char)
        end
    end)
end
