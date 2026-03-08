-- [[ Cryptic Hub - ميزة NoClip المطورة / Advanced NoClip Feature ]]
-- الملف / File: noclip.lua

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local player = game.Players.LocalPlayer
    local noclipActive = false
    local connection

    local function toggleNoclip(active)
        noclipActive = active
        
        if noclipActive then
            connection = RunService.Stepped:Connect(function()
                if noclipActive and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
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
        end
    end

    Tab:AddToggle("اختراق الجدران / NoClip", function(active)
        toggleNoclip(active)
        
        -- نظام التسجيل (اللوق) المزدوج يبقى شغالاً للتوثيق
        if UI.Logger then
            local actionLog = active and "تفعيل / Enabled" or "إيقاف / Disabled"
            UI.Logger("حالة الميزة / Feature State", "قام المستخدم بـ / User performed: " .. actionLog .. " (NoClip)")
        end
        
        -- إشعارات الواجهة تظهر عند التفعيل فقط (إطفاء صامت)
        if active then
            UI:Notify("✅ تم تفعيل اختراق الجدران\n✅ NoClip Enabled")
        end
        -- إذا تم إيقاف الميزة (active = false) لن يظهر أي إشعار وتنطفئ بصمت
    end)
end
