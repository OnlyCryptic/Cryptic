-- [[ Arwa Hub - ميزة التطيير الصامت + حماية Anti-Fling ]]
-- المطور: Arwa | الميزات: تطيير مضمون، حماية تلقائية، مظهر طبيعي

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    
    local isWalkFling = false
    local flingPart = nil

    -- وظيفة إنشاء قطعة التطيير "المدمرة"
    local function createFlingPart()
        if flingPart then flingPart:Destroy() end
        
        flingPart = Instance.new("Part")
        flingPart.Name = "ArwaDestructivePart"
        flingPart.Transparency = 1 -- مخفية
        flingPart.Size = Vector3.new(1.2, 1.2, 1.2) -- حجم مركز لزيادة قوة الاصطدام
        flingPart.CanCollide = true -- يجب أن تصطدم بالآخرين لتطيرهم
        flingPart.Parent = workspace
        
        -- إضافة قوة دوران خرافية
        local bAV = Instance.new("BodyAngularVelocity")
        bAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bAV.AngularVelocity = Vector3.new(0, 45000, 0) -- رفع القوة لضمان التطيير
        bAV.Parent = flingPart
        
        -- إلغاء الجاذبية
        local bF = Instance.new("BodyForce")
        bF.Force = Vector3.new(0, workspace.Gravity * flingPart:GetMass(), 0)
        bF.Parent = flingPart
    end

    Tab:AddToggle("🌪️ تطيير + حماية (Walk Fling)", function(active)
        isWalkFling = active
        if active then
            createFlingPart()
            UI:Notify("✅ التطيير والحماية (Anti-Fling) مفعلان!")
        else
            if flingPart then flingPart:Destroy() end
            UI:Notify("❌ تم إيقاف النظام")
        end
    end)

    Tab:AddParagraph("📝 ملاحقة: بمجرد التفعيل، ستصبحين محصنة ضد التطيير وأي لاعب تلمسينه سيطير فوراً.")

    -- الحلقة الذهبية: دمج التطيير مع الحماية (Anti-Fling)
    runService.Heartbeat:Connect(function()
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if isWalkFling and root then
            if not flingPart or not flingPart.Parent then createFlingPart() end
            
            -- 1. نظام الـ Anti-Fling (حمايتك من الآخرين)
            -- جعل كل أجزاء جسمك لا تصطدم بأحد لكي لا يتم تطييرك
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Velocity = Vector3.new(0, 0, 0) -- منع تراكم السرعة القاتلة
                end
            end

            -- 2. جعل القطعة المخفية تتبعك وتطيرهم
            flingPart.CFrame = root.CFrame
            -- إعطاء القطعة سرعة هجومية
            flingPart.Velocity = Vector3.new(500, 500, 500) 
            
            -- 3. جعل القطعة تتجاهل جسمك أنتِ فقط لكي لا تطيرك
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char}
            params.FilterType = Enum.RaycastFilterType.Exclude
        elseif not isWalkFling and flingPart then
            flingPart:Destroy()
            flingPart = nil
        end
    end)
end
