-- [[ Cryptic Hub - انتقال للهدف / Target TP ]]
-- المطور: يامي (Yami) | الميزات: انتقال آمن، إشعارات 25 ثانية، نظام TimedToggle

return function(Tab, UI)
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer

    -- دالة إشعارات روبلوكس الرسمية (تم الضبط على 25 ثانية)
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 25, 
            })
        end)
    end

    -- استخدام AddTimedToggle لتوحيد شكل السكربت (ينطفئ الزر تلقائياً بعد ثانيتين)
    Tab:AddTimedToggle("انتقال للهدف / Target TP", function(active)
        if active then
            local target = _G.ArwaTarget -- قراءة الهدف من المتغير المرتبط بملف البحث الخاص بك
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            -- التأكد من وجود هدف محدد وجودة شخصيته في الماب
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = target.Character.HumanoidRootPart
                
                if root and targetRoot then
                    -- عملية الانتقال فوق موقع الهدف بمسافة آمنة (3 مسامير) لمنع القلتش
                    root.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
                    
                    SendRobloxNotification("Cryptic Hub", "⚡ تم الانتقال بنجاح إلى: " .. target.DisplayName)
                end
            else
                -- إشعار في حال عدم تحديد لاعب أو اختفاء الهدف
                SendRobloxNotification("Cryptic Hub", "⚠️ حدد هدفاً أولاً من خانة البحث أعلاه!")
            end
        end
    end)
end
