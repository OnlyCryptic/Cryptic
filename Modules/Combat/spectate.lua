-- [[ Cryptic Hub - ميزة مراقبة اللاعبين المطورة ]]
-- الملف: spectate.lua | تحديث: البحث الذكي والتحكم الموحد

return function(Tab, UI)
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    local selectedPlayer = nil
    local isSpectating = false

    local SpectateToggle -- سنحتاج للإشارة إليه لاحقاً

    -- 1. زر عرض النتيجة (الذي يظهر فيه الاسم @اليوزر)
    local ResultBtn = Tab:AddButton("لم يتم العثور على لاعب", function()
        -- عند الضغط على الاسم، يتم مسحه وإيقاف المراقبة
        selectedPlayer = nil
        if isSpectating then SpectateToggle.SetState(false) end
        UI:Notify("تم مسح الاختيار")
    end)

    -- 2. خانة البحث
    Tab:AddInput("البحث عن لاعب", "اكتب بداية الاسم...", function(txt)
        if txt == "" then 
            selectedPlayer = nil
            ResultBtn:SetText("لم يتم العثور على لاعب")
            if isSpectating then SpectateToggle.SetState(false) end
            return 
        end

        local found = nil
        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp and (p.Name:lower():find(txt:lower()) or p.DisplayName:lower():find(txt:lower())) then
                found = p
                break
            end
        end

        if found then
            selectedPlayer = found
            ResultBtn:SetText(found.DisplayName .. " (@" .. found.Name .. ")")
        else
            selectedPlayer = nil
            ResultBtn:SetText("❌ لا يوجد لاعب بهذا الاسم")
            if isSpectating then SpectateToggle.SetState(false) end
        end
    end)

    -- 3. مفتاح تشغيل المراقبة
    SpectateToggle = Tab:AddToggle("تشغيل وضع المراقبة", function(active)
        isSpectating = active
        if active then
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = selectedPlayer.Character.Humanoid
                UI:Notify("تراقب الآن: " .. selectedPlayer.DisplayName)
            else
                UI:Notify("اختر لاعباً أولاً!")
                task.spawn(function() SpectateToggle.SetState(false) end)
            end
        else
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lp.Character.Humanoid
            end
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
