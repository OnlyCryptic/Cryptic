-- [[ Cryptic Hub - ميزة مراقبة اللاعبين المصلحة ]]
-- التحديث: إصلاح البحث عند إغلاق الكيبورد + زر الانتقال

return function(Tab, UI)
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    local selectedPlayer = nil
    local isSpectating = false

    local SpectateToggle -- مرجع للإطفاء التلقائي

    -- 1. خانة البحث (المصلحة)
    local InputField = Tab:AddInput("البحث عن لاعب", "اكتب بداية اليوزر...", function(txt) end)

    -- منطق البحث عند إغلاق الكيبورد
    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then 
            selectedPlayer = nil
            if isSpectating then SpectateToggle.SetState(false) end
            return 
        end

        local bestMatch = nil
        local search = txt:lower()

        -- البحث في "بداية" يوزرات اللاعبين
        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp then
                local pName = p.Name:lower()
                -- التحقق أن اليوزر يبدأ بنفس الحروف المكتوبة
                if string.sub(pName, 1, #search) == search then
                    bestMatch = p
                    break -- نأخذ أول وأقرب لاعب
                end
            end
        end

        if bestMatch then
            selectedPlayer = bestMatch
            InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
            UI:Notify("تم تحديد: " .. bestMatch.DisplayName)
        else
            selectedPlayer = nil
            UI:Notify("❌ لم يتم العثور على لاعب")
            if isSpectating then SpectateToggle.SetState(false) end
        end
    end)

    -- خط فاصل للتنظيم
    Tab:AddLine()

    -- 2. زر تشغيل المراقبة
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
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lp.Character.Humanoid
            end
        end
    end)

    -- 3. زر الانتقال السريع
    Tab:AddButton("انتقال إلى اللاعب المختار", function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            UI:Notify("تم الانتقال لـ " .. selectedPlayer.DisplayName)
        else
            UI:Notify("حدد لاعباً أولاً!")
        end
    end)

    -- تحديث الكاميرا المستمر
    task.spawn(function()
        while task.wait(0.5) do
            if isSpectating and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = selectedPlayer.Character.Humanoid
            end
        end
    end)
end
