-- [[ Cryptic Hub - ميزة NoClip المطورة / Advanced NoClip Feature ]]
-- الملف / File: noclip.lua

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local player = game.Players.LocalPlayer
    local noclipActive = false
    local connection
    
    -- جدول جديد لحفظ حالة التصادم الأصلية لكل جزء من الجسم
    local originalStates = {}

    local function toggleNoclip(active)
        noclipActive = active
        
        if noclipActive then
            -- تصفير الذاكرة عند التفعيل لضمان الدقة
            originalStates = {} 
            
            connection = RunService.Stepped:Connect(function()
                if noclipActive and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            -- إذا لم نقم بحفظ حالة هذا الجزء من قبل، احفظها الآن
                            if originalStates[part] == nil then
                                originalStates[part] = part.CanCollide
                            end
                            -- إلغاء التصادم لاختراق الجدران
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- إيقاف اختراق الجدران
            if connection then
                connection:Disconnect()
                connection = nil
            end
            
            -- إرجاع كل جزء لحالته الأصلية التي كان عليها قبل التفعيل
            for part, originalCollideState in pairs(originalStates) do
                -- التأكد من أن الجزء ما زال موجوداً في اللعبة (اللاعب لم يمت مثلاً)
                if part and part.Parent then
                    part.CanCollide = originalCollideState
                end
            end
            
            -- تفريغ الذاكرة لتخفيف الضغط
            originalStates = {} 
        end
    end

    Tab:AddToggle("اختراق الجدران / NoClip", function(active)
        toggleNoclip(active)
        
        -- نظام التسجيل (اللوق)
        if UI.Logger then
            local actionLog = active and "تفعيل / Enabled" or "إيقاف / Disabled"
            UI.Logger("حالة الميزة / Feature State", "قام المستخدم بـ / User performed: " .. actionLog .. " (NoClip)")
        end
        
        -- إشعار نظام روبلوكس
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = active and "✅ تم تفعيل اختراق الجدران\n✅ NoClip Enabled" or "❌ تم إيقاف اختراق الجدران\n❌ NoClip Disabled",
                Duration = 4
            })
        end)
    end)
end
