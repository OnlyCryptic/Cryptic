-- [[ Cryptic Hub - حماية الإعصار (درع الاختراق الذكي) ]]
-- المطور: أروى (Arwa) | التحديث: اختراق البلوكات السريعة فقط بدون إيقاف حركتها

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    
    local isAntiBlockActive = false
    local ProtectionConnection = nil
    local noclippedParts = {} -- جدول لحفظ البلوكات اللي سوينا لها اختراق عشان ما نكرر الأكواد
    
    -- دالة لتنظيف الدروع عند الإيقاف
    local function clearConstraints()
        local char = Player.Character
        if char then
            local folder = char:FindFirstChild("Cryptic_AntiBlock_NCC")
            if folder then folder:Destroy() end
        end
        noclippedParts = {}
    end

    Tab:AddToggle("حماية من تطيير بلوكات / anti block fling", function(state)
        isAntiBlockActive = state
        
        if isAntiBlockActive then
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Cryptic Hub", Text = "🛡️ درع الاختراق شغال! البلوكات السريعة ستمر عبرك كالهواء.", Duration = 4 }) end)
            
            ProtectionConnection = RunService.Heartbeat:Connect(function()
                local Character = Player.Character
                if not Character then return end
                
                local root = Character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                -- مجلد لحفظ الدروع عشان يكون السكربت نظيف وما يعلق اللعبة
                local nccFolder = Character:FindFirstChild("Cryptic_AntiBlock_NCC")
                if not nccFolder then
                    nccFolder = Instance.new("Folder")
                    nccFolder.Name = "Cryptic_AntiBlock_NCC"
                    nccFolder.Parent = Character
                end
                
                -- إعداد فلتر البحث المكاني (لتجاهل جسم اللاعب نفسه)
                local overlapParams = OverlapParams.new()
                overlapParams.FilterType = Enum.RaycastFilterType.Exclude
                overlapParams.FilterDescendantsInstances = {Character}
                
                -- مسح ذكي وسريع جداً للأجزاء القريبة منك فقط (نطاق 45 متر)
                local nearbyParts = workspace:GetPartBoundsInRadius(root.Position, 45, overlapParams)
                
                for _, part in ipairs(nearbyParts) do
                    -- فحص إذا كانت البلوكة غير مثبتة (Unanchored)
                    if part:IsA("BasePart") and not part.Anchored then
                        
                        -- إذا كانت البلوكة سريعة وممكن تطيرك (سرعة خطية أو دورانية)
                        if part.AssemblyLinearVelocity.Magnitude > 25 or part.AssemblyAngularVelocity.Magnitude > 25 then
                            
                            -- نتأكد إننا ما سوينا لها اختراق من قبل عشان ما نسوي لاق
                            if not noclippedParts[part] then
                                noclippedParts[part] = true
                                
                                -- 🪄 السحر هنا: إنشاء درع عدم تصادم بين شخصيتك والبلوكة فقط!
                                for _, charPart in pairs(Character:GetChildren()) do
                                    if charPart:IsA("BasePart") then
                                        local ncc = Instance.new("NoCollisionConstraint")
                                        ncc.Part0 = charPart
                                        ncc.Part1 = part
                                        ncc.Parent = nccFolder
                                    end
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
            clearConstraints() -- مسح كل دروع الاختراق لترجع البلوكات تصدمك طبيعي
            
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Cryptic Hub", Text = "⚠️ تم إيقاف درع اختراق البلوكات.", Duration = 4 }) end)
        end
    end)
end
