return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Player = game.Players.LocalPlayer
    local isNoFallActive = false
    local NoFallConnection = nil

    Tab:AddToggle("سقوط بدون دمج / nofall", function(state)
        isNoFallActive = state
        
        if isNoFallActive then
            -- نستخدم Heartbeat لمراقبة السقوط في كل جزء من الثانية
            NoFallConnection = RunService.Heartbeat:Connect(function()
                local Character = Player.Character
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    local root = Character.HumanoidRootPart
                    local vel = root.AssemblyLinearVelocity
                    
                    -- إذا كانت سرعة النزول (السقوط) عالية جداً (أقل من -40)
                    -- نثبتها على -40، هذا الرقم يخليك تنزل بسرعة معقولة بدون ما تتدمج
                    if vel.Y < -40 then
                        root.AssemblyLinearVelocity = Vector3.new(vel.X, -40, vel.Z)
                    end
                end
            end)
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "cryptic hub",
                Text = "تم تفعيل حماية السقوط! 🪂 انقز من أي مكان بأمان",
                Duration = 4
            })
        else
            -- إيقاف الحماية
            if NoFallConnection then
                NoFallConnection:Disconnect()
                NoFallConnection = nil
            end
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "cryptic hub",
                Text = "تم إيقاف حماية السقوط.",
                Duration = 3
            })
        end
    end)
end
