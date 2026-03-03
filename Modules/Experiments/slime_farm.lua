-- [[ Cryptic Hub - Slime Evolution Auto Farm ]]
-- المطور: يامي (Yami) | التحديث: انتقال تلقائي وقتل مستمر للسلايم

return function(Tab, UI)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lp = Players.LocalPlayer
    
    local autoFarm = false
    
    -- دالة ذكية للبحث عن السلايم الحي (بدون لاق للجوال)
    local function getLivingSlime()
        local char = lp.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
        
        -- البحث في الـ Workspace عن الوحوش
        -- (إذا كانت الوحوش داخل مجلد معين في اللعبة مثل workspace.Enemies، نقدر نعدلها لاحقاً)
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v ~= char and v:FindFirstChild("HumanoidRootPart") then
                local hum = v:FindFirstChildOfClass("Humanoid")
                -- نتأكد إنه حي وإنه مو لاعب ثاني
                if hum and hum.Health > 0 and not Players:GetPlayerFromCharacter(v) then
                    -- غالباً اسم المودل يحتوي على كلمة Slime أو يكون هو الوحش الوحيد
                    return v 
                end
            end
        end
        return nil
    end

    Tab:AddToggle("⚔️ أوتو فارم (انتقال وقتل السلايم)", function(state)
        autoFarm = state
        
        if autoFarm then
            UI:Notify("✅ تم تشغيل الأوتو فارم للسلايم!")
            task.spawn(function()
                while autoFarm do
                    task.wait(0.1) -- سرعة ممتازة عشان الجوال ما يقلتش
                    pcall(function()
                        local char = lp.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        
                        if root then
                            local targetSlime = getLivingSlime()
                            
                            if targetSlime and targetSlime:FindFirstChild("HumanoidRootPart") then
                                -- 1. الانتقال إلى السلايم (أعلى منه بشوي لتجنب القلتشات)
                                root.CFrame = targetSlime.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0)
                                
                                -- 2. إرسال كود الضرب اللي أرسلته
                                local attackEvent = ReplicatedStorage:FindFirstChild("Utility")
                                if attackEvent then
                                    local network = attackEvent:FindFirstChild("Network")
                                    if network then
                                        local slimeEvent = network:FindFirstChild("SlimeAttackEvent")
                                        if slimeEvent then
                                            slimeEvent:FireServer()
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        else
            UI:Notify("❌ تم إيقاف الأوتو فارم.")
        end
    end)
    
    Tab:AddLine()
end
