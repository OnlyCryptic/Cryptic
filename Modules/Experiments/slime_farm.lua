-- [[ Cryptic Hub - Slime Evolution Auto Farm V2 ]]
-- المطور: يامي (Yami) | التحديث: دعم وحوش السيميوليتر (بدون Humanoid) واستهداف أقرب سلايم

return function(Tab, UI)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lp = Players.LocalPlayer
    
    local autoFarm = false
    
    -- دالة ذكية للبحث عن السلايم (مصممة للسيميوليترات)
    local function getClosestSlime()
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end

        local closestTarget = nil
        local shortestDist = math.huge

        -- البحث في الماب بالكامل
        for _, v in pairs(workspace:GetDescendants()) do
            -- التأكد إنه مو لاعب ثاني
            if v ~= char and not Players:GetPlayerFromCharacter(v) then
                
                -- إذا كان اسمه يحتوي على كلمة Slime (سواء حرف كبير أو صغير)
                if string.match(string.lower(v.Name), "slime") then
                    local targetPart = nil
                    
                    -- تحديد الجزء المسؤول عن مكان السلايم
                    if v:IsA("BasePart") then
                        targetPart = v
                    elseif v:IsA("Model") then
                        targetPart = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                    end

                    if targetPart then
                        -- نتأكد إن السلايم موجود وشفافيته طبيعية (لأن بعضهم يختفي إذا مات)
                        if targetPart.Transparency < 1 then
                            local dist = (root.Position - targetPart.Position).Magnitude
                            -- استهداف الأقرب
                            if dist < shortestDist then
                                shortestDist = dist
                                closestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
        
        return closestTarget
    end

    Tab:AddToggle("⚔️ أوتو فارم (انتقال وقتل السلايم)", function(state)
        autoFarm = state
        
        if autoFarm then
            UI:Notify("✅ تم تشغيل الأوتو فارم المطور!")
            task.spawn(function()
                while autoFarm do
                    task.wait(0.05) -- سرعة نقل وضرب فائقة
                    pcall(function()
                        local char = lp.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        
                        if root then
                            local targetPart = getClosestSlime()
                            
                            if targetPart then
                                -- 1. الانتقال إلى السلايم (أعلى منه بشوي عشان ما تطيح تحت الماب)
                                root.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                                
                                -- 2. إرسال كود الضرب بسرعة
                                local attackEvent = ReplicatedStorage:FindFirstChild("Utility")
                                if attackEvent then
                                    local network = attackEvent:FindFirstChild("Network")
                                    if network then
                                        local slimeEvent = network:FindFirstChild("SlimeAttackEvent")
                                        if slimeEvent then
                                            slimeEvent:FireServer()
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        else
            UI:Notify("❌ تم إيقاف الأوتو فارم.")
        end
    end)
    
    Tab:AddLine()
end
