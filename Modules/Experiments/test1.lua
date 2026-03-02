-- [[ Cryptic Hub - قسم التجارب ]]
-- المطور: Cryptic | التجربة الأولى: تطيير جميع اللاعبين (Fling All)

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer

    -- عنوان للقسم
    Tab:AddLabel("🌪️ تجارب الفيزياء الفتاكة")

    -- زر تطيير الجميع
    Tab:AddButton("🚀 تطيير الجميع (Fling All)", function()
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not root then
            UI:Notify("❌ لم يتم العثور على شخصيتك!")
            return
        end

        UI:Notify("⚠️ جاري تطيير الجميع... استمتع بالمشهد!")

        task.spawn(function()
            -- 1. حفظ مكانك الأصلي عشان ترجع له بعد ما تخلص الجريمة 🤫
            local originalCFrame = root.CFrame

            -- 2. صنع أداة دوران وهمية (BodyAngularVelocity) بقوة لا نهائية
            local spinner = Instance.new("BodyAngularVelocity")
            spinner.Name = "CrypticFling"
            spinner.AngularVelocity = Vector3.new(0, 99999, 0) -- سرعة دوران مرعبة
            spinner.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            spinner.P = math.huge
            spinner.Parent = root

            -- 3. حلقة المرور على كل لاعب في السيرفر
            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                if targetPlayer ~= lp then
                    pcall(function()
                        local targetChar = targetPlayer.Character
                        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                        local targetHum = targetChar and targetChar:FindFirstChild("Humanoid")

                        -- التأكد أن اللاعب حي وموجود
                        if targetRoot and targetHum and targetHum.Health > 0 then
                            local startTime = tick()
                            
                            -- الالتصاق باللاعب لمدة 0.5 ثانية لضمان تطييره
                            while tick() - startTime < 0.5 do
                                RunService.Heartbeat:Wait()
                                if char and root and targetRoot then
                                    -- جعل شخصيتك موازية له تماماً ليطير بقوة
                                    root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 0)
                                    root.Velocity = Vector3.new(0, 0, 0)
                                else
                                    break
                                end
                            end
                        end
                    end)
                end
            end

            -- 4. إيقاف الدوران وتنظيف السكربت
            if spinner then spinner:Destroy() end
            
            -- تصفير سرعة اللاعب عشان ما تطير أنت كمان
            if root then
                root.RotVelocity = Vector3.new(0, 0, 0)
                root.Velocity = Vector3.new(0, 0, 0)
                -- 5. العودة لمكانك الأصلي
                root.CFrame = originalCFrame
            end

            UI:Notify("✅ تمت المهمة بنجاح! تم مسح السيرفر.")
        end)
    end)
end
