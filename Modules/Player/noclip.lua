-- [[ Cryptic Hub - ميزة NoClip المطورة الاحترافية V2 ]]
-- الملف / File: noclip.lua

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local player = game.Players.LocalPlayer
    local noclipConnection

    local function toggleNoclip(active)
        if active then
            -- نستخدم Stepped لأنها تتنفذ قبل حسابات الفيزياء في روبلوكس بثواني
            noclipConnection = RunService.Stepped:Connect(function()
                local char = player.Character
                if char then
                    -- 1. إيقاف التصادم العادي
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                    
                    -- 2. السر الاحترافي: إيقاف استجابة الشخصية للفيزياء (يمنع الارتداد من الجدران السميكة)
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(11) -- Enum.HumanoidStateType.StrafingNoPhysics
                    end
                end
            end)
        else
            -- إيقاف الميزة
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            -- إرجاع حالة الشخصية للطبيعي عشان ما تطيح تحت الأرض
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(8) -- Enum.HumanoidStateType.GettingUp (تنشيط الفيزياء)
                end
            end
        end
    end

    Tab:AddToggle("اختراق الجدران / NoClip", function(active)
        toggleNoclip(active)
        
        -- نظام التسجيل (اللوق) المزدوج
        if UI.Logger then
            local actionLog = active and "تفعيل / Enabled" or "إيقاف / Disabled"
            UI.Logger("حالة الميزة / Feature State", "قام المستخدم بـ / User performed: " .. actionLog .. " (NoClip V2)")
        end
        
        -- إشعار نظام روبلوكس الرسمي عند التفعيل فقط
        if active then
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Cryptic Hub",
                    Text = "👻 تم تفعيل NoClip V2 (اختراق قوي)",
                    Duration = 4
                })
            end)
        end
    end)
end
