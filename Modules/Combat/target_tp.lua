-- [[ Cryptic Hub - انتقال للهدف / Target TP ]]
-- المطور: يامي (Yami) | الميزات: انتقال آمن، إشعارات مزدوجة (عربي/إنجليزي)، نظام TimedToggle

return function(Tab, UI)
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer

    -- دالة الإشعارات المزدوجة (عربي/إنجليزي)
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 10, 
            })
        end)
    end

    -- استخدام AddTimedToggle لتوحيد شكل السكربت (ينطفئ الزر تلقائياً بعد ثانية/ثانيتين)
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
                    
                    Notify(
                        "⚡ تم الانتقال بنجاح إلى: " .. target.DisplayName,
                        "⚡ Successfully teleported to: " .. target.DisplayName
                    )
                end
            else
                -- إشعار في حال عدم تحديد لاعب أو اختفاء الهدف
                Notify(
                    "⚠️ حدد هدفاً أولاً من خانة البحث أعلاه!",
                    "⚠️ Select a target first from the search box above!"
                )
            end
        end
    end)
end
