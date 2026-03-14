-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين (متناسقة مع الواجهة) ]]
-- المطور: يامي | الوصف: تحديد اللاعب عبر مربع نص ثم ضغط زر النسخ

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    -- متغير لحفظ اسم اللاعب الذي ستكتبه
    local targetPlayerName = ""
    
    -- العنوان (بالعربي والإنجليزي كما طلبت)
    Tab:AddParagraph("نسخ سكن / Copy Outfit", "فقط انت تقدر تشوفه / Only you can see it")
    
    -- مربع إدخال اسم اللاعب (تقدر تكتب اسمه كامل أو أول كم حرف بس)
    Tab:AddInput("اسم اللاعب / Player Name", function(text)
        targetPlayerName = text
    end)
    
    -- زر النسخ
    Tab:AddButton("نسخ السكن / Copy Skin", function()
        -- التأكد أنك كتبت اسماً
        if targetPlayerName == "" then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = "❌ يرجى كتابة اسم اللاعب أولاً!",
                Duration = 3
            })
            return
        end
        
        -- نظام ذكي للبحث عن اللاعب (حتى لو كتبت جزء من اسمه)
        local targetPlayer = nil
        local lowerName = string.lower(targetPlayerName)
        for _, p in ipairs(Players:GetPlayers()) do
            if string.lower(string.sub(p.Name, 1, #lowerName)) == lowerName or string.lower(string.sub(p.DisplayName, 1, #lowerName)) == lowerName then
                targetPlayer = p
                break
            end
        end
        
        -- إذا وجدنا اللاعب
        if targetPlayer then
            if targetPlayer == lp then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Cryptic Hub",
                    Text = "⚠️ لا يمكنك نسخ سكنك لنفسك!",
                    Duration = 3
                })
                return
            end
            
            -- عملية نسخ السكن الآمنة (محلياً)
            pcall(function()
                local myChar = lp.Character
                local myHum = myChar and myChar:FindFirstChild("Humanoid")
                if myHum then
                    local targetDesc = Players:GetHumanoidDescriptionFromUserId(targetPlayer.UserId)
                    if targetDesc then
                        myHum:ApplyDescription(targetDesc)
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Cryptic Hub 🎭",
                            Text = "✅ تم نسخ سكن [" .. targetPlayer.DisplayName .. "] بنجاح!",
                            Duration = 4
                        })
                    end
                end
            end)
        else
            -- إذا كان الاسم غير موجود بالسيرفر
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = "❌ لم يتم العثور على اللاعب! تأكد من الاسم.",
                Duration = 3
            })
        end
    end)
    
    Tab:AddLine()
end
