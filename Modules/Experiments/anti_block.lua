return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Player = game.Players.LocalPlayer
    local isAntiBlockActive = false
    local ProtectionConnection = nil

    Tab:AddToggle("حماية من بلوكات سريعة 🛡️", function(state)
        isAntiBlockActive = state
        
        if isAntiBlockActive then
            -- نستخدم Heartbeat ليعمل السكربت بسرعة فائقة لصد الهجمات
            ProtectionConnection = RunService.Heartbeat:Connect(function()
                local Character = Player.Character
                if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
                
                local root = Character.HumanoidRootPart
                
                -- مسح سريع للأجزاء في الخريطة
                for _, part in pairs(workspace:GetDescendants()) do
                    -- التأكد أنها بلوكة، غير مثبتة، وليست من جسمك
                    if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(Character) then
                        
                        -- إذا اقتربت البلوكة منك (داخل نطاق 40 خطوة)
                        if (part.Position - root.Position).Magnitude < 40 then
                            
                            -- 🚨 التعديل هنا: السكربت يتدخل فقط إذا كانت البلوكة تتحرك بسرعة عالية (أكثر من 30)
                            if part.AssemblyLinearVelocity.Magnitude > 30 then
                                -- 1. إيقاف التصادم لتخترقك بأمان
                                part.CanCollide = false 
                                
                                -- 2. تصفير السرعة تماماً لتسقط على الأرض فوراً
                                part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            end
                            
                        end
                    end
                end
            end)
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "الرادار شغال! 🛡️ سيتم صد البلوكات السريعة فقط",
                Duration = 4
            })
        else
            -- إيقاف الحماية
            if ProtectionConnection then
                ProtectionConnection:Disconnect()
                ProtectionConnection = nil
            end
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "تم إيقاف حماية البلوكات.",
                Duration = 3
            })
        end
    end)
end
