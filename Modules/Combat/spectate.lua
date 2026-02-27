-- [[ Cryptic Hub - ميزة مراقبة اللاعبين المطورة ]]
-- الملف: spectate.lua

return function(Tab, UI)
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    local selectedPlayer = nil
    local isSpectating = false

    local function updateCamera()
        if isSpectating and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = selectedPlayer.Character.Humanoid
        else
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lp.Character.Humanoid
            end
        end
    end

    -- 1. خانة البحث عن اللاعب
    local PlayerDisplay = Tab:AddLabel("لم يتم اختيار لاعب")
    
    local SpectateToggle -- سنحتاج للإشارة إليه لاحقاً لإطفائه

    local SearchInput = Tab:AddInput("البحث عن لاعب", "اكتب بداية الاسم هنا...", function(txt)
        if txt == "" then
            selectedPlayer = nil
            PlayerDisplay:SetText("لم يتم اختيار لاعب")
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
            PlayerDisplay:SetText("المستهدف: " .. found.DisplayName .. " (@" .. found.Name .. ")")
        else
            selectedPlayer = nil
            PlayerDisplay:SetText("❌ لا يوجد لاعب بهذا الاسم")
            if isSpectating then SpectateToggle.SetState(false) end
        end
    end)

    -- خط فاصل للترتيب
    Tab:AddLine()

    -- 2. زر تشغيل المراقبة
    SpectateToggle = Tab:AddToggle("تشغيل وضع المراقبة", function(active)
        isSpectating = active
        if active then
            if selectedPlayer then
                updateCamera()
                UI:Notify("أنت الآن تشاهد: " .. selectedPlayer.DisplayName)
            else
                UI:Notify("الرجاء البحث عن لاعب أولاً!")
                task.spawn(function() SpectateToggle.SetState(false) end)
            end
        else
            updateCamera()
            UI:Notify("تم العودة لكاميرا شخصيتك")
        end
    end)

    -- نظام الإطفاء التلقائي عند خروج اللاعب
    players.PlayerRemoving:Connect(function(player)
        if selectedPlayer and player == selectedPlayer then
            UI:Notify("اللاعب الذي تراقبه غادر السيرفر!")
            selectedPlayer = nil
            PlayerDisplay:SetText("اللاعب غادر السيرفر")
            if isSpectating then SpectateToggle.SetState(false) end
        end
    end)

    -- تحديث الكاميرا المستمر
    task.spawn(function()
        while task.wait(0.5) do
            if isSpectating then updateCamera() end
        end
    end)
end
