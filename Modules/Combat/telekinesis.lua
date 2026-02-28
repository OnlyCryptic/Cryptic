return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Player = game.Players.LocalPlayer
    local isShieldActive = false
    local ShieldConnection = nil

    Tab:AddToggle("درع التحريك الذهني 🌪️", function(state)
        isShieldActive = state
        
        if isShieldActive then
            local angle = 0
            
            -- نستخدم Heartbeat عشان يتحدث الكود مع كل فريم في اللعبة (سريع جداً)
            ShieldConnection = RunService.Heartbeat:Connect(function()
                local Character = Player.Character
                if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
                
                local root = Character.HumanoidRootPart
                angle = angle + 3 -- سرعة دوران البلوكات حولك
                
                -- جمع كل البلوكات القريبة والغير مثبتة
                local targetParts = {}
                for _, part in pairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(Character) then
                        -- نسحب البلوكات اللي تبعد عنك مسافة 100 فقط عشان ما يعلق السيرفر
                        if (part.Position - root.Position).Magnitude < 100 then
                            table.insert(targetParts, part)
                        end
                    end
                end
                
                -- ترتيب البلوكات في دائرة حول اللاعب
                for i, part in ipairs(targetParts) do
                    -- 🛡️ الحماية: إغلاق التصادم عشان البلوكة تخترقك لو اقتربت وما تطيرك!
                    part.CanCollide = false 
                    
                    -- حساب المسافة وتوزيع البلوكات
                    local mathAngle = math.rad(angle + (i * (360 / #targetParts)))
                    local radius = 15 -- المسافة بينك وبين البلوكات (بعيدة عنك)
                    
                    local x = math.cos(mathAngle) * radius
                    local z = math.sin(mathAngle) * radius
                    
                    -- تصفير سرعتها العشوائية عشان نتحكم فيها تماماً
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                    
                    -- نقل البلوكة لمكانها الدائري
                    part.CFrame = CFrame.new(root.Position + Vector3.new(x, 0, z))
                end
            end)
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "تم تفعيل درع التحريك الذهني وحماية الاختراق! 🛡️",
                Duration = 3
            })
        else
            -- إيقاف الدرع
            if ShieldConnection then
                ShieldConnection:Disconnect()
                ShieldConnection = nil
            end
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "تم إيقاف الدرع.",
                Duration = 3
            })
        end
    end)
end
