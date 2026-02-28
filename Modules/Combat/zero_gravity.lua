return function(Tab, UI)
    local Player = game.Players.LocalPlayer
    local isZeroGravity = false
    local OriginalGravity = workspace.Gravity

    Tab:AddToggle("العوم في الفضاء 🚀", function(state)
        isZeroGravity = state
        
        if isZeroGravity then
            -- جعل الجاذبية صفر
            workspace.Gravity = 0 
            
            -- إعطاء الشخصية دفعة للأعلى عشان تطير فوراً بدون قفز
            local Character = Player.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 15, 0)
            end
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "تم تفعيل انعدام الجاذبية! أنت تسبح في الفضاء 🌌",
                Duration = 3
            })
        else
            -- إرجاع الجاذبية لوضعها الطبيعي
            workspace.Gravity = OriginalGravity 
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "عادت الجاذبية لطبيعتها 🌍",
                Duration = 3
            })
        end
    end)
end
