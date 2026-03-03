-- [[ Cryptic Hub - القائمة الرئيسية ]]
-- المطور: يامي (Yami) | التحديث: واجهة مختصرة ونظيفة جداً

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    -- 1. البطاقة التعريفية الأنيقة
    if Tab.AddProfileCard then
        Tab:AddProfileCard(lp)
    end

    Tab:AddLine()

    -- 2. زر الديسكورد
    Tab:AddButton("🔗 نسخ رابط الديسكورد", function()
        pcall(function()
            setclipboard("https://discord.gg/QSvQJs7BdP")
            UI:Notify("✅ تم نسخ رابط الديسكورد بنجاح!")
        end)
    end)

    Tab:AddLine()

    -- 3. الحقوق
    Tab:AddLabel("© جميع الحقوق محفوظة للمطور: يامي (Yami)")
    Tab:AddLabel("ديسكورد التواصل: @d8u_")
end
