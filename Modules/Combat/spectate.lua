-- [[ Cryptic Hub - ميزة مراقبة اللاعبين المحدثة ]]
-- الملف: spectate.lua | تحديث: بحث البداية فقط + إغلاق الكيبورد

return function(Tab, UI)
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    local selectedPlayer = nil
    local isSpectating = false
    local SpectateToggle

    -- خانة البحث (الخط الفاصل سيتم وضعه خارجياً بواسطة main.lua)
    local InputField = Tab:AddInput("البحث عن لاعب لمراقبته", "اكتب بداية اليوزر...", function(txt) end)

    -- البحث لا يعمل إلا عند إغلاق الكيبورد (FocusLost)
    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then 
            selectedPlayer = nil
            if isSpectating then SpectateToggle.SetState(false) end
            return 
        end

        local bestMatch = nil
        local search = txt:lower()

        -- البحث في "بداية" يوزرات اللاعبين فقط
        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp then
                local pName = p.Name:lower()
                -- التحقق أن اليوزر يبدأ بنفس الحروف المكتوبة (Prefix match)
                if string.sub(pName, 1, #search) == search then
                    bestMatch = p
                    break 
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

    -- زر تشغيل المراقبة (لا يوجد AddLine هنا)
    SpectateToggle = Tab:AddToggle("تشغيل وضع المراقبة", function(active)
        isSpectating = active
        if active and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = selectedPlayer.Character.Humanoid
        else
            camera.CameraSubject = lp.Character.Humanoid
            if active then task.spawn(function() SpectateToggle.SetState(false) end) end
        end
    end)

    -- زر الانتقال السريع
    Tab:AddButton("انتقال إلى اللاعب المختار", function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
        end
    end)

    -- نظام المتابعة المستمر
    task.spawn(function()
        while task.wait(0.5) do
            if isSpectating and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = selectedPlayer.Character.Humanoid
            end
        end
    end)
end
