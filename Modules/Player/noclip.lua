-- [[ Cryptic Hub - ميزة الاختراق الشبحي (CFrame Ghost NoClip) ]]
-- الملف / File: noclip.lua

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local player = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera

    local noclipActive = false
    local speed = 50 -- سرعة المشي عبر الجدران (تقدرين تعدلينها)
    local connection

    local function toggleGhostNoclip(active)
        noclipActive = active
        local char = player.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if not root or not hum then return end

        if noclipActive then
            -- 1. إيقاف وقوف الشخصية الطبيعي (عشان ما تطيح أو تتأثر بالجاذبية والجدران)
            hum.PlatformStand = true
            
            -- 2. التحرك المستمر بدون فيزياء (CFrame)
            connection = RunService.RenderStepped:Connect(function(deltaTime)
                if not char or not root then return end
                
                local moveDir = Vector3.new(0,0,0)
                local lookVector = camera.CFrame.LookVector
                local rightVector = camera.CFrame.RightVector
                
                -- التحكم باستخدام أزرار الحركة (WASD)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + lookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - lookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + rightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - rightVector end
                
                -- النقل الفوري المتكرر (هذا اللي يخلي مستحيل أي جدار يوقفك)
                root.CFrame = root.CFrame + (moveDir * speed * deltaTime)
                
                -- زيادة تأكيد: إخفاء التصادم من كل القطع
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            -- إيقاف الميزة وإرجاع الشخصية لوضعها الطبيعي
            if connection then
                connection:Disconnect()
                connection = nil
            end
            if hum then
                hum.PlatformStand = false
            end
        end
    end

    Tab:AddToggle("اختراق الجدران / NoClip", function(active)
        toggleGhostNoclip(active)
        
        if UI.Logger then
            local actionLog = active and "تفعيل / Enabled" or "إيقاف / Disabled"
            UI.Logger("حالة الميزة", actionLog .. " (Ghost NoClip)")
        end
        
        if active then
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Cryptic Hub",
                    Text = "👻 تم تفعيل الاختراق الشبحي المطلق!",
                    Duration = 3
                })
            end)
        end
    end)
end
