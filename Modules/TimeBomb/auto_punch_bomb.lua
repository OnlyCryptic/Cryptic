-- [[ Cryptic Hub - اللكم/التمرير التلقائي V2 ]]
-- المطور: Cryptic | التحديث: نظام رصد القنابل الذكي (يدعم المجسمات والأدوات)

return function(Tab, UI)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lp = Players.LocalPlayer

    local autoPass = false

    Tab:AddToggle("🥊 تمرير/لكم تلقائي (Auto-Punch)", function(active)
        autoPass = active
        if active then
            UI:Notify("🔥 تم التفعيل! سيتم قصف أقرب لاعب بمجرد رصد القنبلة.")
        else
            UI:Notify("🛑 تم إيقاف التمرير التلقائي.")
        end
    end)

    -- دالة البحث عن أقرب ضحية
    local function getClosestPlayer()
        local closest = nil
        local shortestDistance = math.huge
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        
        if not myRoot then return nil end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hum = p.Character:FindFirstChild("Humanoid")
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

    -- [[ التحديث الجديد: فحص شامل للقنبلة ]]
    local function hasBomb()
        if not lp.Character then return false end
        
        -- الفحص 1: هل هي أداة (Tool) كلاسيكية؟
        if lp.Character:FindFirstChildOfClass("Tool") then return true end
        
        -- الفحص 2: هل اللعبة أضافت مجسم (Part/Model/Accessory) اسمه يحتوي على كلمة Bomb؟
        for _, child in pairs(lp.Character:GetChildren()) do
            if string.find(child.Name:lower(), "bomb") then
                return true
            end
        end
        
        -- الفحص 3: في بعض الألعاب القنبلة توضع داخل HumanoidRootPart كـ Particle أو Fire
        local root = lp.Character:FindFirstChild("HumanoidRootPart")
        if root and (root:FindFirstChild("Bomb") or root:FindFirstChild("TimeBomb")) then
            return true
        end

        return false
    end

    -- المحرك الفتاك
    task.spawn(function()
        local punchRemote = ReplicatedStorage:WaitForChild("Packages")
            :WaitForChild("Networker")
            :WaitForChild("Holder")
            :WaitForChild("RE/RoundService/Punch")

        while task.wait(0.05) do 
            if autoPass then
                pcall(function()
                    if hasBomb() then
                        local targetRoot = getClosestPlayer()
                        if targetRoot and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                            local myRoot = lp.Character.HumanoidRootPart
                            
                            -- الانتقال خلف اللاعب مباشرة
                            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
                            
                            -- لكمه فوراً
                            punchRemote:FireServer()
                        end
                    end
                end)
            end
        end
    end)
end
