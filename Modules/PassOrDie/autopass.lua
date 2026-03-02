-- [[ Arwa Hub - تحويل القنبلة التلقائي (Pass or Die) ]]
-- المطور: Arwa | الوظيفة: رمي القنبلة تلقائياً للاعب اللي جنبك

return function(Tab, UI)
    -- مسار الريموت اللي أنت اكتشفته
    local passRemote = game:GetService("ReplicatedStorage"):WaitForChild("Gameplay"):WaitForChild("Core"):WaitForChild("Default"):WaitForChild("Remotes"):WaitForChild("Pass")
    
    local autoPass = false

    Tab:AddToggle("💣 تحويل تلقائي (Auto-Pass)", function(active)
        autoPass = active
        if active then
            UI:Notify("🔥 تم تفعيل الـ Auto-Pass! السكربت بيرمي القنبلة عنك.")
        else
            UI:Notify("🛑 تم الإيقاف.")
        end
    end)

    -- حلقة تكرار سريعة جداً تشتغل في الخلفية
    task.spawn(function()
        while task.wait(0.1) do -- يفحص كل جزء من الثانية
            if autoPass then
                -- نستخدم pcall عشان لو السيرفر تأخر في الرد ما يخرب السكربت حقك
                pcall(function()
                    -- إرسال أمر "تحويل لليسار" للسيرفر
                    passRemote:InvokeServer("Left")
                end)
            end
        end
    end)
end
