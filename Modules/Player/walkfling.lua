-- [[ Arwa Hub - ميزة التطيير الصامت (بدون دوران للشخصية) ]]
-- المطور: Arwa | المظهر: طبيعي 100% | التقنية: القطعة المخفية

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    
    local isWalkFling = false
    local flingPart = nil

    -- وظيفة إنشاء وتدشين قطعة التطيير المخفية
    local function createFlingPart()
        if flingPart then flingPart:Destroy() end
        
        flingPart = Instance.new("Part")
        flingPart.Name = "ArwaSilentFling"
        flingPart.Transparency = 1 -- مخفية تماماً
        flingPart.CanCollide = false
        flingPart.Anchored = false
        flingPart.Size = Vector3.new(2, 2, 2)
        flingPart.Parent = workspace
        
        -- إضافة قوة الدوران للقطعة وليس للاعب
        local bAV = Instance.new("BodyAngularVelocity")
        bAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bAV.AngularVelocity = Vector3.new(0, 30000, 0) -- السرعة في القطعة المخفية
        bAV.Parent = flingPart
        
        -- إلغاء الجاذبية للقطعة لكي لا تسقط
        local bF = Instance.new("BodyForce")
        bF.Force = Vector3.new(0, workspace.Gravity * flingPart:GetMass(), 0)
        bF.Parent = flingPart
    end

    Tab:AddToggle("🌪️ تطير لاعبين", function(active)
        isWalkFling = active
        if active then
            createFlingPart()
            UI:Notify("✅ تم التفعيل. شخصيتك طبيعية والقطعة المخفية جاهزة!")
        else
            if flingPart then flingPart:Destroy() end
            UI:Notify("❌ تم إيقاف التطيير")
        end
    end)

    Tab:AddParagraph("📝 ملاحقة: فقط المس لاعبين وسوف يطيرون.")

    -- حلقة التحديث: جعل القطعة تتبع اللاعب بدقة
    runService.Heartbeat:Connect(function()
        if isWalkFling and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local root = lp.Character.HumanoidRootPart
            
            if not flingPart or not flingPart.Parent then createFlingPart() end
            
            -- جعل القطعة المخفية في نفس موقع اللاعب تماماً
            flingPart.CFrame = root.CFrame
            flingPart.Velocity = root.Velocity -- لضمان بقائها معك أثناء المشي السريع
            
            -- إلغاء تصادم اللاعب مع الآخرين لضمان لمسهم للقطعة المخفية
            for _, part in pairs(lp.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        elseif not isWalkFling and flingPart then
            flingPart:Destroy()
            flingPart = nil
        end
    end)
end
