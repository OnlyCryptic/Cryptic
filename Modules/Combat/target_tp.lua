-- [[ Cryptic Hub - انتقال إلى هدف ]]
-- المطور: Cryptic | التحديث: استخدام نظام الزر المؤقت (ينطفئ بعد ثانيتين)

return function(Tab, UI)
    -- استخدام AddTimedToggle بدلاً من AddButton لتوحيد الشكل
    Tab:AddTimedToggle("🚀 انتقال إلى لاعب", function(active)
        if active then
            local target = _G.ArwaTarget -- قراءة الهدف المحدد من الذاكرة العامة
            local lp = game.Players.LocalPlayer
            
            -- التأكد من وجود الهدف وجودة شخصيته في الماب
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then 
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    -- عملية الانتقال فوق رأس الهدف بـ 3 بلاطات
                    lp.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0) 
                end
            else
                -- تنبيه في حال لم يتم اختيار لاعب من القائمة
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Cryptic Hub",
                        Text = "⚠️ حدد هدفاً أولاً من قائمة اللاعبين!",
                        Duration = 3
                    })
                end)
            end
        end
    end)
end
