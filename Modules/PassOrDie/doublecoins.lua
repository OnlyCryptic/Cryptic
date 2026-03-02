-- [[ Cryptic Hub - تدبيل الفلوس الذكي ]]
-- المطور: Cryptic | التحديث: رصد بدء الجولة تلقائياً لمنع رسائل الخطأ

return function(Tab, UI)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lp = Players.LocalPlayer
    
    local autoDoubleCoins = false

    Tab:AddToggle("💰 تدبيل الفلوس (Cryptic Smart-x2)", function(active)
        autoDoubleCoins = active
        if active then
            UI:Notify("💸 تم التفعيل! السكربت ينتظر بدء الجولة بصمت...")
        else
            UI:Notify("🛑 تم إيقاف تدبيل الفلوس.")
        end
    end)

    -- [[ إضافة احترافية: إخفاء لوحة الخطأ لو حاولت تظهر ]]
    task.spawn(function()
        local PlayerGui = lp:WaitForChild("PlayerGui")
        PlayerGui.DescendantAdded:Connect(function(desc)
            if autoDoubleCoins and (desc:IsA("TextLabel") or desc:IsA("TextButton")) then
                if desc.Text and string.find(desc.Text, "You can't use that right now") then
                    local screenGui = desc:FindFirstAncestorWhichIsA("ScreenGui")
                    if screenGui then 
                        screenGui.Enabled = false -- إخفاء اللوحة فوراً قبل لا تشوفها
                    end
                end
            end
        end)
    end)

    -- [[ المحرك الذكي: رصد التليبورت وبدء الجولة ]]
    task.spawn(function()
        local powersRemotes = ReplicatedStorage:WaitForChild("Powers"):WaitForChild("Core"):WaitForChild("Default"):WaitForChild("Remotes")
        local buyRemote = powersRemotes:WaitForChild("Buy")
        local useRemote = powersRemotes:WaitForChild("Use")

        local lastPos = nil

        while task.wait(0.5) do 
            if autoDoubleCoins then
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root then
                    if lastPos then
                        -- حساب المسافة: إذا تحركت أكثر من 50 مسمار فجأة، يعني اللعبة نقلتك للساحة!
                        local dist = (root.Position - lastPos).Magnitude
                        
                        if dist > 50 then
                            task.wait(0.5) -- انتظار نصف ثانية عشان السيرفر يستوعب إنك داخل الجولة
                            pcall(function()
                                -- شراء واستخدام القدرة فوراً
                                buyRemote:InvokeServer("7")
                                task.wait(0.2)
                                useRemote:InvokeServer("7")
                            end)
                        end
                    end
                    lastPos = root.Position
                end
            end
        end
    end)
end
