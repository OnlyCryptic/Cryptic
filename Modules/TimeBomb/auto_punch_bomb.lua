-- [[ Cryptic Hub - اللكم/التمرير التلقائي (Auto-Punch) ]]
-- المطور: Cryptic | التحديث: الانتقال السريع لأقرب لاعب واللكم فور إمساك القنبلة

return function(Tab, UI)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lp = Players.LocalPlayer

    local autoPass = false

    Tab:AddToggle("🥊 تمرير/لكم تلقائي (Auto-Punch)", function(active)
        autoPass = active
        if active then
            UI:Notify("🔥 تم التفعيل! بمجرد إمساك القنبلة سيتم قصف أقرب لاعب.")
        else
            UI:Notify("🛑 تم إيقاف التمرير التلقائي.")
        end
    end)

    -- [[ دالة البحث عن أقرب ضحية ]]
    local function getClosestPlayer()
        local closest = nil
        local shortestDistance = math.huge
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        
        if not myRoot then return nil end

        for _, p in pairs(Players:GetPlayers()) do
            -- التأكد أنه لاعب آخر وشخصيته موجودة
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hum = p.Character:FindFirstChild("Humanoid")
                -- التأكد أن اللاعب حي (وليس ميتاً أو مختفياً)
                if hum and hum.Health > 0 then
                    local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closest = p.Character.HumanoidRootPart
                    end
                end
            end
        end
        return closest
    end

    -- [[ دالة التحقق من إمساك القنبلة ]]
    local function hasBomb()
        -- في أغلب الألعاب، عندما تمسك القنبلة تتحول إلى (Tool) داخل شخصيتك
        if lp.Character and lp.Character:FindFirstChildOfClass("Tool") then
            return true
        end
        return false
    end

    -- [[ المحرك الفتاك (Teleport & Punch) ]]
    task.spawn(function()
        -- مسار ريموت اللكم اللي أنت استخرجته
        local punchRemote = ReplicatedStorage:WaitForChild("Packages")
            :WaitForChild("Networker")
            :WaitForChild("Holder")
            :WaitForChild("RE/RoundService/Punch")

        while task.wait(0.05) do -- سرعة استجابة خارقة (50 جزء من الثانية)
            if autoPass then
                pcall(function()
                    if hasBomb() then
                        local targetRoot = getClosestPlayer()
                        if targetRoot and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                            local myRoot = lp.Character.HumanoidRootPart
                            
                            -- 1. الانتقال اللحظي (Teleport) خلف أقرب لاعب مباشرة بمسافة 2 مسمار
                            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
                            
                            -- 2. إرسال أمر اللكم للسيرفر عشان يعطيه القنبلة
                            punchRemote:FireServer()
                        end
                    end
                end)
            end
        end
    end)
end
