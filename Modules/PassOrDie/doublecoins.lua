-- [[ Cryptic Hub - تدبيل الفلوس الذكي V6 ]]
-- المطور: Cryptic | التحديث: إصلاح تعليق العد التنازلي (Visible Check) + تأخير الرادار لضمان الترسبن

return function(Tab, UI)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lp = Players.LocalPlayer
    
    local autoDoubleCoins = false
    local minPlayersRequired = 12

    -- 1. أزرار التحكم
    Tab:AddToggle("💰 تدبيل الفلوس (Cryptic Smart-x2)", function(active)
        autoDoubleCoins = active
        if active then
            UI:Notify("💸 تم التفعيل! السكربت ينتظر انتقالك للساحة...")
        else
            UI:Notify("🛑 تم إيقاف تدبيل الفلوس.")
        end
    end)

    Tab:AddInput("👥 الحد الأدنى للاعبين (رقم)", "الافتراضي 12", function(txt)
        local num = tonumber(txt)
        if num then 
            minPlayersRequired = num 
            UI:Notify("⚙️ تم تعيين الحد الأدنى إلى: " .. num .. " لاعبين.")
        end
    end)

    -- [[ القاتل الصامت: مسح اللوحات المزعجة ]]
    task.spawn(function()
        while task.wait(0.2) do
            if autoDoubleCoins then
                pcall(function()
                    local PlayerGui = lp:FindFirstChild("PlayerGui")
                    if PlayerGui then
                        for _, gui in pairs(PlayerGui:GetDescendants()) do
                            if gui:IsA("TextLabel") and gui.Text then
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

    -- [[ الدالة 1 المصلحة: التأكد أن النص "ظاهر" فعلياً وليس مخفياً ]]
    local function isGameCountingDown()
        local PlayerGui = lp:FindFirstChild("PlayerGui")
        if not PlayerGui then return false end
        
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Text then
                if string.find(gui.Text:lower(), "starting game") then
                    -- التحقق ما إذا كان النص وأي إطار يحمله مرئياً (Visible)
                    local current = gui
                    local isVisible = true
                    while current and current ~= PlayerGui do
                        if current:IsA("GuiObject") and not current.Visible then
                            isVisible = false
                            break
                        end
                        current = current.Parent
                    end
                    
                    if isVisible then return true end
                end
            end
        end
        return false
    end

    -- [[ الدالة 2: رادار حساب اللاعبين ]]
    local function getPlayersInCircle()
        local count = 0
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return 0 end

        for _, player in ipairs(Players:GetPlayers()) do
            local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local dist = (targetRoot.Position - myRoot.Position).Magnitude
                if dist <= 150 then
                    count = count + 1
                end
            end
        end
        return count
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
                        
                        -- 1. اكتشاف الانتقال لساحة اللعب
                        if dist > 50 then
                            task.spawn(function()
                                -- UI:Notify("🔍 [نظام]: تم رصد الساحة، ننتظر بدء الجولة...") -- إشعار مخفي للمطور
                                
                                task.wait(1)
                                
                                -- 2. انتظار اختفاء العد التنازلي تماماً من الشاشة
                                while isGameCountingDown() do
                                    task.wait(0.2)
                                end
                                
                                -- 3. الجولة بدأت! ننتظر 1.5 ثانية لضمان ترسبن كل اللاعبين بالساحة
                                task.wait(1.5)
                                
                                -- 4. تشغيل الرادار
                                local playersInArena = getPlayersInCircle()
                                
                                if playersInArena >= minPlayersRequired then
                                    UI:Notify("✅ عدد اللاعبين (" .. playersInArena .. ")! جاري تفعيل التدبيل...")
                                    
                                    for i = 1, 5 do
                                        if not autoDoubleCoins then break end
                                        task.spawn(function()
                                            pcall(function()
                                                buyRemote:InvokeServer("7")
                                                task.wait(0.1)
                                                useRemote:InvokeServer("7")
                                            end)
                                        end)
                                        task.wait(1.5)
                                    end
                                else
                                    UI:Notify("⚠️ عدد اللاعبين قليل (" .. playersInArena .. "). تم إلغاء التدبيل!")
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
