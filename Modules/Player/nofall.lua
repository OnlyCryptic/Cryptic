-- [[ Cryptic Hub - ميزة سقوط بدون دمج / NoFall ]]
-- المطور: يامي (Yami) | الميزة: حماية من ضرر السقوط / Feature: Fall damage protection

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Player = game.Players.LocalPlayer
    local isNoFallActive = false
    local NoFallConnection = nil

    Tab:AddToggle("سقوط بدون دمج / NoFall", function(state)
        isNoFallActive = state
        
        if isNoFallActive then
            -- نستخدم Heartbeat لمراقبة السقوط في كل جزء من الثانية / Use Heartbeat to monitor falling every frame
            NoFallConnection = RunService.Heartbeat:Connect(function()
                local Character = Player.Character
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    local root = Character.HumanoidRootPart
                    local vel = root.AssemblyLinearVelocity
                    
                    -- إذا كانت سرعة النزول (السقوط) عالية جداً (أقل من -40)
                    -- نثبتها على -40، لمنع الدمج / Cap falling speed at -40 to prevent damage
                    if vel.Y < -40 then
                        root.AssemblyLinearVelocity = Vector3.new(vel.X, -40, vel.Z)
                    end
                end
            end)
            
            -- إشعار التفعيل المزدوج يظهر فقط عند التشغيل / Dual Notification on activation only
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Cryptic Hub",
                    Text = "تم تفعيل حماية السقوط! 🪂\nNoFall protection activated! 🪂",
                    Duration = 4
                })
            end)
        else
            -- إيقاف الحماية بصمت / Disable protection silently
            if NoFallConnection then
                NoFallConnection:Disconnect()
                NoFallConnection = nil
            end
            
            -- لم نضع إشعاراً هنا بناءً على طلبك ليكون الإطفاء هادئاً
        end
    end)
end
