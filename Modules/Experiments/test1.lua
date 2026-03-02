-- [[ Cryptic Hub - قسم التجارب ]]
-- المطور: Cryptic | التجربة: إعصار تطيير الجميع (Auto Fling All) كزر تشغيل

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer

    local autoFling = false
    local spinner = nil

    Tab:AddLabel("🌪️ تجارب الفيزياء الفتاكة")

    Tab:AddToggle("🚀 إعصار تطيير الجميع (Auto Fling)", function(active)
        autoFling = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if active then
            UI:Notify("🔥 تم تشغيل الإعصار! جاري تصفية السيرفر...")
            if root and hum then
                -- [[ الحل هنا ]]: إلغاء وقوف الشخصية عشان تقدر تدور بحرية
                hum.PlatformStand = true 
                
                -- إضافة قوة الدوران
                spinner = Instance.new("BodyAngularVelocity")
                spinner.Name = "CrypticSpinner"
                spinner.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                spinner.AngularVelocity = Vector3.new(0, 50000, 0) -- سرعة جنونية
                spinner.Parent = root
            end
        else
            UI:Notify("🛑 تم إيقاف الإعصار.")
            -- إرجاع الشخصية لحالتها الطبيعية
            if hum then hum.PlatformStand = false end
            if spinner then spinner:Destroy() end
            if root then
                root.RotVelocity = Vector3.new(0, 0, 0)
                root.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)

    -- [[ محرك المطاردة التلقائي ]]
    task.spawn(function()
        while task.wait(0.1) do
            if autoFling then
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root then
                    -- المرور على كل لاعب في السيرفر
                    for _, targetPlayer in ipairs(Players:GetPlayers()) do
                        -- التأكد أن زر التشغيل لا يزال فعالاً وأن الهدف ليس أنت
                        if autoFling and targetPlayer ~= lp then
                            pcall(function()
                                local tChar = targetPlayer.Character
                                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                                local tHum = tChar and tChar:FindFirstChild("Humanoid")

                                -- إذا كان اللاعب حي وموجود
                                if tRoot and tHum and tHum.Health > 0 then
                                    local startTime = tick()
                                    
                                    -- الالتصاق باللاعب لمدة 0.3 ثانية لضمان تطييره بقوة
                                    while tick() - startTime < 0.3 and autoFling do
                                        RunService.Heartbeat:Wait()
                                        if root and tRoot then
                                            -- النقل المستمر لداخل شخصية الهدف
                                            root.CFrame = tRoot.CFrame
                                            root.Velocity = Vector3.new(0, 0, 0) -- منع شخصيتك من الطيران بعيداً
                                        else
                                            break
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
    end)
end
