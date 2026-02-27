-- [[ Cryptic Hub - ميزة مراقبة اللاعبين المطورة ]]
-- الملف: spectate.lua | تحديث: البحث الذكي والترتيب المنظم

return function(Tab, UI)
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    local selectedPlayer = nil
    local isSpectating = false

    -- 1. كشف اللاعبين (ESP)
    Tab:AddToggle("كشف اللاعبين (ESP)", function(v)
        -- كود الـ ESP هنا
    end)

    -- 2. وضع الخط الفاصل تحت الـ ESP مباشرة للتنظيم
    Tab:AddLine()

    -- 3. نظام البحث الذكي (تم حذف الخانة الزائدة)
    local SpectateToggle -- سنستخدمه لاحقاً

    local SearchBox = Tab:AddInput("البحث عن لاعب لمراقبته", "اكتب اسم اللاعب هنا...", function(txt)
        if txt == "" then
            selectedPlayer = nil
            if isSpectating then SpectateToggle.SetState(false) end
            return
        end

        -- البحث التلقائي بمجرد الكتابة
        local found = nil
        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp and (p.Name:lower():find(txt:lower()) or p.DisplayName:lower():find(txt:lower())) then
                found = p
                break
            end
        end

        if found then
            selectedPlayer = found
            -- إظهار الاسم واليوزر داخل التيكست بوكس ليسهل عليكِ معرفة من اخترتِ
            UI:Notify("المستهدف الحالي: " .. found.DisplayName)
        else
            selectedPlayer = nil
            if isSpectating then SpectateToggle.SetState(false) end
        end
    end)

    -- 4. مفتاح تشغيل المراقبة
    SpectateToggle = Tab:AddToggle("تشغيل وضع المراقبة", function(active)
        isSpectating = active
        if active then
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = selectedPlayer.Character.Humanoid
                UI:Notify("أنت الآن تراقب: " .. selectedPlayer.DisplayName)
            else
                UI:Notify("لم يتم العثور على اللاعب أو أنه غير موجود!")
                task.spawn(function() SpectateToggle.SetState(false) end)
            end
        else
            -- العودة للكاميرا العادية
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lp.Character.Humanoid
            end
            UI:Notify("تم العودة لكاميرا شخصيتك")
        end
    end)

    -- إطفاء تلقائي عند خروج اللاعب
    players.PlayerRemoving:Connect(function(player)
        if selectedPlayer and player == selectedPlayer then
            selectedPlayer = nil
            if isSpectating then SpectateToggle.SetState(false) end
        end
    end)

    -- تحديث الكاميرا المستمر طالما الميزة مفعلة
    task.spawn(function()
        while task.wait(0.5) do
            if isSpectating and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = selectedPlayer.Character.Humanoid
            end
        end
    end)
end
