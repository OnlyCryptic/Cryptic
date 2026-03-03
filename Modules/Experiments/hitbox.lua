-- [[ Arwa Hub - ميزة تكبير الرؤوس (Hitbox Expander) ]]
-- المطور: Arwa | الميزات: تكبير الرأس، رؤية شفافة، لمس سهل

return function(Tab, UI)
    local players = game:GetService("Players")
    local runService = game:GetService("RunService")
    local lp = players.LocalPlayer
    
    local hitboxSize = 10 -- الحجم الافتراضي
    local isHitboxEnabled = false
    local targetPart = "Head" -- الجزء الذي سيتم تكبيره

    Tab:AddToggle("🎯 تفعيل تكبير الرؤوس (Hitbox)", function(active)
        isHitboxEnabled = active
        if active then
            UI:Notify("✅ تم تفعيل تكبير الرؤوس! المسافة أصبحت أقرب")
        else
            -- إرجاع الرؤوس لحجمها الطبيعي عند الإغلاق
            for _, p in pairs(players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild(targetPart) then
                    p.Character[targetPart].Size = Vector3.new(2, 1, 1) -- الحجم الطبيعي التقريبي
                    p.Character[targetPart].Transparency = 0
                end
            end
            UI:Notify("❌ تم إرجاع الأحجام الطبيعية")
        end
    end)

    -- خانة إدخال الحجم (بدلاً من السلايدر لتجنب الأخطاء)
    Tab:AddInput("📏 حجم الهيت بوكس (1 إلى 50)", "10", function(val)
        local n = tonumber(val)
        if n then 
            hitboxSize = math.clamp(n, 1, 50)
            UI:Notify("تم ضبط الحجم على: " .. hitboxSize)
        end
    end)

    -- حلقة التحديث المستمر لضمان بقاء التكبير حتى لو مات الخصم وعاد
    runService.RenderStepped:Connect(function()
        if isHitboxEnabled then
            for _, p in pairs(players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild(targetPart) then
                    local part = p.Character[targetPart]
                    part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    part.Transparency = 0.6 -- جعلها شفافة قليلاً لكي لا تحجب الرؤية
                    part.CanCollide = false -- لكي لا تتعثري بها أثناء المشي
                end
            end
        end
    end)
end
