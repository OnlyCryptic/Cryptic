-- [[ Cryptic Hub - هجوم الأشياء (Part Flinger) ]]
-- الملف / File: part_flinger.lua
-- القسم: تجارب (Experiments)

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    
    local targetName = ""
    local isActive = false
    local connection
    local unanchoredParts = {}

    -- [[ دالة البحث عن اللاعب المستهدف ]]
    local function GetTargetPlayer(name)
        if name == "" then return nil end
        name = name:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name then
                return p
            end
        end
        return nil
    end

    -- [[ تحديث قائمة الأشياء غير المثبتة بذكاء (لمنع اللاق) ]]
    task.spawn(function()
        while task.wait(3) do
            if isActive then
                local tempParts = {}
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v.Anchored then
                        -- استثناء شخصيات اللاعبين (عشان ما نسحب أجزاء اللاعبين نفسهم)
                        local model = v:FindFirstAncestorOfClass("Model")
                        if not (model and model:FindFirstChildOfClass("Humanoid")) then
                            table.insert(tempParts, v)
                        end
                    end
                end
                unanchoredParts = tempParts
            end
        end
    end)

    -- [[ خانة كتابة اسم الهدف ]]
    Tab:AddTextbox("اسم اللاعب / Target Name", function(text)
        targetName = text
        if text ~= "" then
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Cryptic Hub",
                    Text = "🎯 تم تحديد الهدف: " .. text,
                    Duration = 2
                })
            end)
        end
    end)

    -- [[ زر التشغيل ]]
    Tab:AddToggle("هجوم الأشياء / Part Flinger", function(active)
        isActive = active
        
        if UI.Logger then
            local actionLog = active and "تفعيل" or "إيقاف"
            UI.Logger("تجارب", actionLog .. " هجوم الأشياء على: " .. tostring(targetName))
        end

        if isActive then
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Cryptic Hub",
                    Text = "🌪️ جاري سحب الأشياء للهدف!",
                    Duration = 3
                })
            end)

            -- حلقة التكرار السريعة اللي تلصق الأشياء في الهدف
            connection = RunService.Heartbeat:Connect(function()
                if not isActive then return end
                
                local targetPlayer = GetTargetPlayer(targetName)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = targetPlayer.Character.HumanoidRootPart
                    
                    for _, part in ipairs(unanchoredParts) do
                        if part and part.Parent then
                            -- 1. نقل الشيء للهدف مع مسافة عشوائية صغيرة (يصير كأنه سرب نحل يهاجمه)
                            part.CFrame = targetHRP.CFrame * CFrame.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
                            
                            -- 2. إعطاء الأشياء سرعة دوران خيالية عشان تفجر فيزياء الهدف ويطير
                            part.AssemblyLinearVelocity = Vector3.new(0, 500, 0)
                            part.AssemblyAngularVelocity = Vector3.new(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500))
                            
                            -- 3. منع الأشياء من التداخل مع الكاميرا حقتك أنتِ
                            part.CanCollide = false 
                        end
                    end
                end
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Cryptic Hub",
                    Text = "🛑 تم إيقاف هجوم الأشياء",
                    Duration = 3
                })
            end)
        end
    end)
end
