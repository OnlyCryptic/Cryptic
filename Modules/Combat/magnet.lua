-- [[ Cryptic Hub - مغناطيس السيرفر V1 ]]
-- المطور: Cryptic | الميزات: سحب كل القطع غير المثبتة، خفيف على الجوال، FE حقيقي

return function(Tab, UI)
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isMagnet = false
    local unanchoredParts = {}

    -- وظيفة للبحث عن القطع غير المثبتة بذكاء (بدون ما نسحب اللاعبين)
    local function scanForParts()
        unanchoredParts = {} -- تفريغ القائمة القديمة
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Anchored then
                -- التأكد أن القطعة ليست جزءاً من شخصيتك أو شخصية لاعب آخر
                if not v:IsDescendantOf(lp.Character) and not v.Parent:FindFirstChild("Humanoid") then
                    table.insert(unanchoredParts, v)
                end
            end
        end
    end

    Tab:AddToggle("🧲 مغناطيس السيرفر (Magnet)", function(active)
        isMagnet = active
        if active then
            UI:Notify("🔍 جاري فحص الماب وجمع القطع...")
            scanForParts()
            UI:Notify("✨ تم تفعيل المغناطيس! القطع ستتجمع أمامك.")
        else
            unanchoredParts = {}
            UI:Notify("❌ تم إيقاف المغناطيس")
        end
    end)

    -- حلقة تحديث القائمة كل 3 ثواني (خفيفة جداً على المعالج)
    task.spawn(function()
        while task.wait(3) do
            if isMagnet then
                scanForParts()
            end
        end
    end)

    -- حلقة السحب الفعلي للقطع (تعمل بسلاسة لتجنب اللاج)
    task.spawn(function()
        while task.wait(0.1) do
            if isMagnet then
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root then
                    for _, part in pairs(unanchoredParts) do
                        -- التأكد أن القطعة لا تزال موجودة وغير مثبتة
                        if part and part.Parent and not part.Anchored then
                            -- سحب القطعة وجعلها تدور أمامك بمسافة 4 مسامير
                            part.CFrame = root.CFrame * CFrame.new(math.random(-3, 3), math.random(0, 4), -4)
                            -- تصفير سرعتها لكي لا تتطاير وتسبب إزعاج
                            part.Velocity = Vector3.new(0, 0, 0)
                            part.RotVelocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end
        end
    end)
end
