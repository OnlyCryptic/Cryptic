-- [[ Cryptic Hub - ميزة NoClip المطورة ]]
-- الملف: noclip.lua

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local player = game.Players.LocalPlayer
    local noclipActive = false
    local connection

    -- وظيفة تفعيل/إيقاف اختراق الجدران
    local function toggleNoclip(active)
        noclipActive = active
        
        if noclipActive then
            -- استخدام Stepped هو الأفضل لمنع التصادم في كل Frame
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
            -- إيقاف الحلقة عند التعطيل
            if connection then
                connection:Disconnect()
                connection = nil
            end
            -- إعادة التصادم للوضع الطبيعي (اختياري، سيعود عند الحركة)
        end
    end

    -- إضافة التحكم للواجهة باستخدام AddToggle (اللمبة)
    Tab:AddToggle("اختراق الجدران (NoClip)", function(active)
        toggleNoclip(active)
        
        -- إرسال تقرير المراقبة
        if UI.Logger then
            UI.Logger("تغيير حالة ميزة", "قام المستخدم بـ " .. (active and "تفعيل" or "إيقاف") .. " اختراق الجدران")
        end
        
        UI:Notify(active and "تم تفعيل اختراق الجدران" or "تم إيقاف اختراق الجدران")
    end)
end
