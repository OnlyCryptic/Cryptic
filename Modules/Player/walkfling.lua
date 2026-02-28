-- [[ Arwa Hub - إعصار الاختراق (Walk Fling + Ghost Mode) ]]
-- المطور: Arwa | الميزات: اختراق اللاعبين، دوران خارق، مشي سريع

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    
    local isFlinging = false
    local visualSpinSpeed = 50 -- سرعة الدوران المرئي
    local customWalkSpeed = 70 -- سرعة المشي (تمت زيادتها)
    local originalWalkSpeed = 16

    Tab:AddToggle("تطيير لاعبين", function(active)
        isFlinging = active
        local char = lp.Character
        local hum = char and char:FindFirstChild("Humanoid")
        
        if active then
            if hum then hum.WalkSpeed = customWalkSpeed end
            UI:Notify("👻 وضع الشبح مفعل! يمكنك الآن اختراق اللاعبين وتطييرهم")
        else
            if hum then hum.WalkSpeed = originalWalkSpeed end
            UI:Notify("❌ تم إيقاف النظام")
        end
    end)

    Tab:AddParagraph("📝 ملاحقة: يمكنكِ الآن المشي 'داخل' اللاعبين؛ وبمجرد تداخل جسمكِ معهم سيطيرون فوراً.")

    -- الحلقة الفيزيائية (تستخدم Stepped لضمان إلغاء التصادم)
    runService.Stepped:Connect(function()
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if isFlinging and root then
            -- 1. خاصية الاختراق (No-Collision)
            -- هذا الكود يسمح لكِ بالمرور من خلال اللاعبين الآخرين
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false -- إلغاء التصادم تماماً
                end
            end

            -- 2. الدوران المرئي السريع
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(visualSpinSpeed), 0)

            -- 3. قوة التطيير (RotVelocity)
            -- جعلناها "غير محدودة" لضمان أقوى تطيير ممكن عند التلامس الداخلي
            root.RotVelocity = Vector3.new(0, 200000, 0) 
            
            -- 4. الثبات الأرضي (منع شخصيتك من الطيران العشوائي)
            root.Velocity = Vector3.new(0, -10, 0) 
        end
    end)
end
