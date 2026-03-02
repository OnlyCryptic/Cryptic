-- [[ Cryptic Hub - تدبيل الفلوس الذكي V3 (بدون توقيت ثابت) ]]
-- المطور: Cryptic | التحديث: رصد بدء الجولة فعلياً من خلال قراءة نصوص واجهة اللعبة

return function(Tab, UI)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lp = Players.LocalPlayer
    
    local autoDoubleCoins = false

    Tab:AddToggle("💰 تدبيل الفلوس (Cryptic Smart-x2)", function(active)
        autoDoubleCoins = active
        if active then
            UI:Notify("💸 تم التفعيل! السكربت يراقب الشاشة ولن يخطئ التوقيت أبداً.")
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
                            if gui:IsA("TextLabel") and gui.Text == "You can't use that right now but you were not charged" then
                                local mainGui = gui:FindFirstAncestorWhichIsA("ScreenGui")
                                if mainGui then mainGui:Destroy() end
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
                -- يبحث عن كلمة "starting game" اللي تظهر أسفل الشاشة
                if string.find(gui.Text:lower(), "starting game") then
                    return true -- نعم، العد التنازلي شغال
                end
            end
        end
        return false -- لا، الجولة بدأت أو نحن في اللوبي
    end

    -- [[ المحرك الرئيسي ]]
    task.spawn(function()
        local powersRemotes = ReplicatedStorage:WaitForChild("Powers"):WaitForChild("Core"):WaitForChild("Default"):WaitForChild("Remotes")
        local buyRemote = powersRemotes:WaitForChild("Buy")
        local useRemote = powersRemotes:WaitForChild("Use")

        local lastPos = nil

        while task.wait(0.2) do 
            if autoDoubleCoins then
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root then
                    if lastPos then
                        local dist = (root.Position - lastPos).Magnitude
                        
                        -- 1. السكربت لاحظ إنك انتقلت للساحة!
                        if dist > 50 then
                            
                            -- 2. [[ الحل العبقري ]]: السكربت يعلق هنا وينتظر بصمت.. 
                            -- لن يكمل الكود حتى تختفي جملة "starting game" من الشاشة
                            repeat 
                                task.wait(0.1) 
                            until not isGameCountingDown()
                            
                            -- 3. بمجرد اختفاء النص (الجولة بدأت فعلياً الآن!):
                            pcall(function()
                                buyRemote:InvokeServer("7")
                                task.wait(0.1) -- جزء من الثانية فقط للسيرفر
                                useRemote:InvokeServer("7")
                                UI:Notify("✅ بدأت الجولة! تم تفعيل التدبيل بنجاح.")
                            end)
                        end
                    end
                    lastPos = root.Position
                end
            end
        end
    end)
end
