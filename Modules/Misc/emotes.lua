-- [[ Cryptic Hub - سكربت الرقصات (All Emotes) ]]
-- المطور: Arwa | تشغيل واجهة الرقصات الخارجية

return function(Tab, UI)
    -- زر تشغيل السكربت
    Tab:AddButton("تشغيل سكربت الرقصات", function()
        UI:Notify("⏳ جاري تحميل الرقصات... يرجى الانتظار في الماب")
        
        -- تشغيل السكربت باستخدام pcall لمنع أي أخطاء من إيقاف كربتك هاب
        pcall(function()
            loadstring(game:HttpGet("http://scriptblox.com/raw/Baseplate-Fe-All-Emote-7386"))()
        end)
    end)

    -- إضافة الملاحظة التحذيرية تحته مباشرة
    Tab:AddParagraph("⚠️ ملاحظة هامة: يحتاج سكربت الرقصات إلى دقيقتين على الأقل حتى يتم تفعيله بالكامل داخل السيرفر، يرجى الانتظار بعد الضغط.")
end
