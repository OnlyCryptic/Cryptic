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
                
                -- مسح سريع لكل الأجزاء في الخريطة
                for _, part in pairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(Character) then
                        
                        -- إذا اقتربت البلوكة منك (مسافة 40)
                        if (part.Position - root.Position).Magnitude < 40 then
                            
                            -- 1. إيقاف التصادم (تخترقك)
                            part.CanCollide = false 
                            
                            -- 2. إبطال السرعة (إيقاف هجوم السكربتات الأخرى)
                            if part.AssemblyLinearVelocity.Magnitude > 30 then
                                part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            end
                            
                        end
                    end
                end
            end)
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "تم تفعيل الدرع المضاد للبلوكات! 🛡️ لا أحد يستطيع تطييرك",
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
