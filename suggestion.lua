-- [[ Cryptic Hub - Suggestions & Feedback Module ]]
-- المطور: مدمج | قسم إرسال الاقتراحات إلى الديسكورد

return function(Tab, UI)
    local userMessage = ""

    Tab:AddParagraph("💡 قسم الاقتراحات والشكاوي\nاكتب رسالتك براحتك لتحت.")

    Tab:AddLine()

    -- استدعاء المربع الكبير الجديد اللي ضفناه
    local MessageInput = Tab:AddLargeInput("الرسالة / Message", "اكتب اقتراحك، أو بلغ عن مشكلة هنا...", function(text)
        userMessage = text
    end)

    -- زر الإرسال والحذف التلقائي
    Tab:AddButton("🚀 إرسال الرسالة / Send", function()
        -- التأكد أن اللاعب كتب رسالة صالحة
        if userMessage == "" or string.len(userMessage) < 3 then
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Cryptic Hub ⚠️",
                    Text = "الرجاء كتابة رسالة صالحة قبل الإرسال!\nPlease write a valid message!",
                    Duration = 3
                })
            end)
            return
        end

        -- الإرسال للويب هوك الرابع (OnSuggestion)
        if getgenv().CrypticLog then
            getgenv().CrypticLog(
                "OnSuggestion", 
                "💡 رسالة / اقتراح جديد من لاعب", 
                16766720, -- لون ذهبي
                {
                    {name = "📝 محتوى الرسالة:", value = "```\n" .. userMessage .. "\n```", inline = false}
                }
            )
            
            -- إشعار نجاح الإرسال (عربي / إنجليزي)
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Cryptic Hub ✅",
                    Text = "تم إرسال رسالتك بنجاح، شكراً لدعمك!\nMessage sent successfully, Thank you!",
                    Duration = 5
                })
            end)
            
            -- [[ حذف الرسالة من المربع تلقائياً بعد الإرسال ]]
            MessageInput.SetText("")
            userMessage = "" -- تصفير المتغير
        else
            -- في حالة عدم وجود دالة الإرسال
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Cryptic Hub ❌",
                    Text = "حدث خطأ في الاتصال بالخادم.\nConnection error.",
                    Duration = 3
                })
            end)
        end
    end)
end
