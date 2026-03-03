-- [[ Cryptic Hub - حماية الإعصار والبلوكات السريعة ]]
-- المطور: يامي (Yami) | التحديث: مسح مكاني ذكي (بدون لاق) + تدمير محركات الـ Fling

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Player = game.Players.LocalPlayer
    local isAntiBlockActive = false
    local ProtectionConnection = nil

    Tab:AddToggle("حماية من تطيير بلوكات / anti block fling", function(state)
        isAntiBlockActive = state
        
        if isAntiBlockActive then
            UI:Notify("🛡️ الرادار شغال! سيتم تدمير أي إعصار بلوكات.")
            
            ProtectionConnection = RunService.Heartbeat:Connect(function()
                local Character = Player.Character
                if not Character then return end
                
                local root = Character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                -- إعداد فلتر البحث المكاني (لتجاهل جسم اللاعب نفسه)
                local overlapParams = OverlapParams.new()
                overlapParams.FilterType = Enum.RaycastFilterType.Exclude
                overlapParams.FilterDescendantsInstances = {Character}
                
                -- مسح ذكي وسريع جداً للأجزاء القريبة منك فقط (نطاق 45 خطوة)
                local nearbyParts = workspace:GetPartBoundsInRadius(root.Position, 45, overlapParams)
                
                for _, part in ipairs(nearbyParts) do
                    if part:IsA("BasePart") and not part.Anchored then
                        
                        -- فحص السرعة الخطية والدورانية (سكربتات الإعصار تعتمد على الدوران العنيف)
                        if part.AssemblyLinearVelocity.Magnitude > 30 or part.AssemblyAngularVelocity.Magnitude > 30 then
                            
                            -- 1. إيقاف التصادم لتخترقك بأمان
                            part.CanCollide = false 
                            
                            -- 2. تصفير السرعة تماماً
                            part.AssemblyLinearVelocity = Vector3.zero
                            part.AssemblyAngularVelocity = Vector3.zero
                            
                            -- 3. تدمير أي محرك مخفي (BodyMover) يسبب دوران البلوكة
                            for _, modifier in pairs(part:GetChildren()) do
                                if modifier:IsA("BodyMover") or modifier:IsA("Constraint") or modifier:IsA("LinearVelocity") or modifier:IsA("AngularVelocity") then
                                    modifier:Destroy()
                                end
                            end
                            
                        end
                    end
                end
            end)
            
        else
            -- إيقاف الحماية
            if ProtectionConnection then
                ProtectionConnection:Disconnect()
                ProtectionConnection = nil
            end
            
            UI:Notify("⚠️ تم إيقاف حماية البلوكات.")
        end
    end)
end
