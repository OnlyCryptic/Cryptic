-- [[ Cryptic Hub - القائمة الرئيسية (معلومات وبطاقة اللاعب) ]]
-- المطور: Cryptic | التحديث: إضافة البطاقة الشخصية ومعلومات المطورين

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    -- 1. استدعاء البطاقة التعريفية (صورتك، اسمك، رتبتك)
    if Tab.AddProfileCard then
        Tab:AddProfileCard(lp)
    end

    Tab:AddLine()

    -- 2. معلومات السكربت 
    Tab:AddLabel("📜 Cryptic Hub V7.0")
    Tab:AddParagraph("مرحباً بك في أقوى سكربت مخصص بالكامل لأجهزة الجوال (صُمم خصيصاً للعمل بسلاسة على أجهزة عاديه).\n\nاضغط على الأقسام الجانبية لاستكشاف المزايا.")

    Tab:AddLine()

    -- 3. فريق التطوير
    Tab:AddLabel("👨‍💻 فريق التطوير (Cryptic Team)")
    Tab:AddParagraph("👑 Cryptic: المؤسس والمطور الرئيسي للمحرك.\n\n⚙️ cryptic: مبرمج الواجهات ونظام الفيزياء (الطيران والجاذبية).")

    Tab:AddLine()

    -- 4. الدعم والروابط
    Tab:AddButton("🔗 نسخ رابط الديسكورد", function()
        pcall(function()
            setclipboard("https://discord.gg/QSvQJs7BdP")
            UI:Notify("✅ تم نسخ رابط الديسكورد بنجاح!")
        end)
    end)
    
    Tab:AddLabel("© جميع الحقوق محفوظة لـ Cryptic Team")
end
