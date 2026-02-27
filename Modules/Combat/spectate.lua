-- [[ Cryptic Hub - ميزة مراقبة اللاعبين الذكية ]]
-- الملف: spectate.lua | تحديث: البحث ببادئة الاسم + الدمج في TextBox

return function(Tab, UI)
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    local selectedPlayer = nil
    local isSpectating = false

    local SpectateToggle -- مرجع لمفتاح التشغيل

    -- 1. كود الـ ESP (يأتي من ملف esp.lua تلقائياً بفضل main.lua)
    
    -- 2. خانة البحث الذكية (تظهر فيها النتائج)
    local SearchBox
    SearchBox = Tab:AddInput("البحث عن لاعب لمراقبته", "اكتب بداية الاسم هنا...", function(txt)
        -- إذا تم مسح النص (أو ضغط المستخدم عليه)، نوقف كل شيء
        if txt == "" then
            selectedPlayer = nil
            if isSpectating then SpectateToggle.SetState(false) end
            return
        end

        -- البحث في بداية اليوزر أو بداية اسم العرض (Prefix Search)
        local found = nil
        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp then
                local name = p.Name:lower()
                local display = p.DisplayName:lower()
                local search = txt:lower()
                
                -- التأكد أن البحث يطابق "بداية" الاسم (Starting with)
                if string.sub(name, 1, #search) == search or string.sub(display, 1, #search) == search then
                    found = p
                    break
                end
            end
        end

        if found then
            selectedPlayer = found
            -- كتابة النتيجة داخل الـ TextBox فور العثور عليها
            SearchBox.SetText(found.DisplayName .. " (@" .. found.Name .. ")")
            UI:Notify("تم تحديد: " .. found.DisplayName)
        else
            selectedPlayer = nil
            if isSpectating then SpectateToggle.SetState(false) end
        end
    end)

    -- 3. مفتاح تشغيل المراقبة
    SpectateToggle = Tab:AddToggle("تشغيل وضع المراقبة", function(active)
        isSpectating = active
        if active then
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = selectedPlayer.Character.Humanoid
            else
                UI:Notify("ابحث عن لاعب أولاً!")
                task.spawn(function() SpectateToggle.SetState(false) end)
            end
        else
            -- العودة للكاميرا العادية
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lp.Character.Humanoid
            end
        end
    end)

    -- تحديث الكاميرا المستمر وتتبع خروج اللاعب
    players.PlayerRemoving:Connect(function(p)
        if selectedPlayer and p == selectedPlayer then
            selectedPlayer = nil
            if isSpectating then SpectateToggle.SetState(false) end
            SearchBox.SetText("")
        end
    end)

    task.spawn(function()
        while task.wait(0.5) do
            if isSpectating and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = selectedPlayer.Character.Humanoid
            end
        end
    end)
end
