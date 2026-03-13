-- [[ Cryptic Hub - Suggestions & Feedback Module (Bilingual) ]]
-- المطور: مدمج | قسم إرسال الاقتراحات إلى الديسكورد (عربي/إنجليزي)

return function(Tab, UI)
    local userMessage = ""

    -- 🟢 الحل هنا: تم فصل العنوان عن المحتوى بفاصلة (,) لكي يترتب بشكل صحيح
    Tab:AddParagraph(
        "💡 قسم الاقتراحات والشكاوى / Suggestions", 
        "اكتب رسالتك هنا بكل حرية، ستصل للمطور مباشرة.\nWrite your message freely here, it will be sent directly to the developer."
    )

    Tab:AddLine()

    -- مربع الكتابة مزدوج اللغة
    local MessageInput = Tab:AddLargeInput(
        "الرسالة / Message", 
        "اكتب اقتراحك أو مشكلتك هنا... / Write your suggestion or bug here...", 
        function(text)
            userMessage = text
        end
    )

    -- زر الإرسال مزدوج اللغة
    Tab:AddButton("🚀 إرسال الرسالة / Send Message", function()
        -- التأكد أن اللاعب كتب رسالة صالحة
        if userMessage == "" or string.len(userMessage) < 3 then
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Cryptic Hub ⚠️",
                    Text = "الرجاء كتابة رسالة صالحة!\nPlease write a valid message!",
                    Duration = 3
                })
            end)
            return
        end

        -- الإرسال للويب هوك (OnSuggestion)
        if getgenv().CrypticLog then
            getgenv().CrypticLog(
                "OnSuggestion", 
                "💡 رسالة جديدة / New Message", 
                16766720, -- لون ذهبي
                {
                    {name = "📝 محتوى الرسالة / Message Content:", value = "```\n" .. userMessage .. "\n```", inline = false}
                }
            )
            
            -- إشعار نجاح الإرسال (عربي / إنجليزي)
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Cryptic Hub ✅",
                    Text = "تم الإرسال بنجاح، شكراً!\nSent successfully, Thank you!",
                    Duration = 5
                })
            end)
            
            -- 🟢 تم حل مشكلة مسح النص بعد الإرسال
            if MessageInput and MessageInput.SetText then
                MessageInput:SetText("")
            end
            userMessage = "" -- تصفير المتغير
        else
            -- في حالة خطأ الاتصال
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Cryptic Hub ❌",
                    Text = "حدث خطأ في الاتصال.\nConnection error.",
                    Duration = 3
                })
            end)
        end
    end)
end
