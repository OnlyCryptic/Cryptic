-- [[ Cryptic Hub - تدبيل الفلوس الذكي V4 ]]
-- المطور: Cryptic | التحديث: نظام المحاولات المتكررة (ضمان 100%) + انتظار تحميل الواجهة

return function(Tab, UI)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lp = Players.LocalPlayer
    
    local autoDoubleCoins = false

    Tab:AddToggle("💰 تدبيل الفلوس (Cryptic Smart-x2)", function(active)
        autoDoubleCoins = active
        if active then
            UI:Notify("💸 تم التفعيل! السكربت مزود بنظام التكرار لضمان التفعيل.")
        else
            UI:Notify("🛑 تم إيقاف تدبيل الفلوس.")
        end
    end)

    -- [[ القاتل الصامت: مسح اللوحات المزعجة كإجراء احتياطي ]]
    task.spawn(function()
        while task.wait(0.2) do
            if autoDoubleCoins then
                pcall(function()
                    local PlayerGui = lp:FindFirstChild("PlayerGui")
                    if PlayerGui then
                        for _, gui in pairs(PlayerGui:GetDescendants()) do
                            if gui:IsA("TextLabel") and gui.Text then
                                -- البحث عن اللوحة وإخفائها
                                if string.find(gui.Text, "You can't use that right now") then
                                    local mainGui = gui:FindFirstAncestorWhichIsA("ScreenGui")
                                    if mainGui then mainGui:Destroy() end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- [[ الدالة الذكية: تقرأ الشاشة لتعرف هل العد التنازلي شغال؟ ]]
    local function isGameCountingDown()
        local PlayerGui = lp:FindFirstChild("PlayerGui")
        if not PlayerGui then return false end
        
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Text then
                if string.find(gui.Text:lower(), "starting game") then
                    return true
                end
            end
        end
        return false
    end

    -- [[ المحرك الرئيسي ]]
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
                        local dist = (root.Position - lastPos).Magnitude
                        
                        -- 1. اكتشاف التليبورت (الانتقال للساحة)
                        if dist > 50 then
                            task.spawn(function()
                                -- [[ التعديل الأول ]]: ننتظر ثانية واحدة لضمان ظهور النص على الشاشة
                                task.wait(1)
                                
                                -- 2. ننتظر حتى يختفي نص "starting game"
                                while isGameCountingDown() do
                                    task.wait(0.2)
                                end
                                
                                -- 3. الجولة بدأت فعلياً!
                                UI:Notify("✅ الجولة بدأت! جاري تأكيد تفعيل التدبيل...")
                                
                                -- [[ التعديل الثاني الجبار ]]: محاولة التفعيل 5 مرات متتالية لضمان النجاح
                                for i = 1, 5 do
                                    if not autoDoubleCoins then break end
                                    
                                    task.spawn(function()
                                        pcall(function()
                                            buyRemote:InvokeServer("7")
                                            task.wait(0.1)
                                            useRemote:InvokeServer("7")
                                        end)
                                    end)
                                    
                                    -- ننتظر ثانية ونصف بين كل محاولة تأكيد
                                    task.wait(1.5)
                                end
                            end)
                        end
                    end
                    lastPos = root.Position
                end
            end
        end
    end)
end
