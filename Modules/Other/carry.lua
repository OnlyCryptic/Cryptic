-- [[ Cryptic Hub - المصعد الفيزيائي ]]
-- المطور: يامي (Yami) | التحديث: إصلاح الفيزياء، إزالة اللاق، وتسريع الاستجابة

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    local isCarrying = false
    local liftHeight = -7
    local liftSpeed = 0.05 
    local currentTarget = nil
    local liftConnection = nil

    -- 1. خانة البحث الذكية (بدون حلقة انتظار تسبب لاق)
    Tab:AddInput("حدد الهدف 🎯", "اكتب اسم اللاعب هنا...", function(txt)
        if txt == "" then currentTarget = nil return end
        
        local search = txt:lower()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and (p.Name:lower():sub(1, #search) == search or p.DisplayName:lower():sub(1, #search) == search) then
                currentTarget = p
                break 
            end
        end
    end)

    -- زر لتأكيد الهدف بعد كتابته
    Tab:AddButton("تأكيد الهدف ✅", function()
        if currentTarget then
            UI:Notify("🎯 تم تحديد: " .. currentTarget.DisplayName)
        else
            UI:Notify("❌ لم يتم العثور على اللاعب!")
        end
    end)

    -- 2. زر تشغيل المصعد
    Tab:AddToggle("تشغيل المصعد 🚀", function(state)
        isCarrying = state
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if isCarrying then
            if not currentTarget or not currentTarget.Character then
                UI:Notify("⚠️ الرجاء تحديد لاعب موجود أولاً!")
                isCarrying = false
                return
            end
            
            liftHeight = -7 -- يبدأ من تحت الأرض
            if hum then hum.PlatformStand = true end
            
            UI:Notify("🚀 جاري رفع: " .. currentTarget.DisplayName)
            
            -- تشغيل حلقة الرفع
            liftConnection = RunService.Heartbeat:Connect(function()
                if not isCarrying or not currentTarget or not currentTarget.Character then return end
                
                local tChar = currentTarget.Character
                local tRoot = tChar:FindFirstChild("HumanoidRootPart")

                if root and tRoot then
                    -- جعل الأطراف نفاذة باستثناء الجذع لمنع القلتشات، وإعطاء قوة رفع (Velocity)
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = (part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso")
                            part.Velocity = Vector3.new(0, 45, 0) -- قوة الدفع للأعلى
                        end
                    end

                    -- الصعود التدريجي
                    if liftHeight < 4 then liftHeight = liftHeight + liftSpeed end
                    
                    -- التمركز تحت الهدف بوضعية أفقية (نايم على ظهره لرفع أفضل)
                    root.CFrame = CFrame.new(tRoot.Position.X, tRoot.Position.Y + liftHeight, tRoot.Position.Z) * CFrame.Angles(math.rad(-90), 0, 0)
                end
            end)

        else
            -- الإيقاف وإرجاع الطبيعة
            if liftConnection then
                liftConnection:Disconnect()
                liftConnection = nil
            end
            
            if hum then hum.PlatformStand = false end
            if root then 
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
            end
            UI:Notify("🛑 تم إيقاف المصعد")
        end
    end)
end
