-- [[ Cryptic Hub - ميزة مراقبة اللاعبين ]]
-- الملف: spectate.lua

return function(Tab, UI)
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    local selectedPlayer = nil
    local isSpectating = false

    -- وظيفة تحديث الكاميرا
    local function updateCamera()
        if isSpectating and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = selectedPlayer.Character.Humanoid
        else
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lp.Character.Humanoid
            end
        end
    end

    -- 1. خانة البحث
    Tab:AddInput("البحث عن لاعب", "اكتب اسم اللاعب هنا...", function(txt)
        local results = {}
        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp and (p.Name:lower():find(txt:lower()) or p.DisplayName:lower():find(txt:lower())) then
                table.insert(results, p.DisplayName .. " (@" .. p.Name .. ")")
            end
        end
        -- تحديث القائمة المنسدلة بالنتائج
        if _G.UpdatePlayerList then _G.UpdatePlayerList(results) end
    end)

    -- 2. قائمة اللاعبين (Dropdown)
    local initialNames = {}
    for _, p in pairs(players:GetPlayers()) do
        if p ~= lp then table.insert(initialNames, p.DisplayName .. " (@" .. p.Name .. ")") end
    end

    local PlayerDrop = Tab:AddDropdown("اختر لاعباً لمراقبته", initialNames, function(val)
        -- استخراج اليوزر من النص (الموجود بين القوسين @)
        local targetUser = val:match("@(%w+)")
        selectedPlayer = players:FindFirstChild(targetUser)
        UI:Notify("تم اختيار: " .. val)
        if isSpectating then updateCamera() end
    end)

    -- لجعل خانة البحث قادرة على تحديث القائمة
    _G.UpdatePlayerList = function(newList)
        PlayerDrop:Update(newList)
    end

    -- 3. زر التشغيل/الإطفاء
    Tab:AddToggle("تشغيل وضع المراقبة", function(active)
        isSpectating = active
        if active then
            if selectedPlayer then
                updateCamera()
                UI:Notify("أنت الآن تشاهد " .. selectedPlayer.DisplayName)
            else
                UI:Notify("الرجاء اختيار لاعب من القائمة أولاً!")
            end
        else
            updateCamera() -- سيعود للكاميرا العادية
            UI:Notify("تم العودة لكاميرا شخصيتك")
        end
    end)

    -- تحديث تلقائي في حال موت اللاعب الذي تراقبه أو دخول لاعبين جدد
    task.spawn(function()
        while task.wait(1) do
            if isSpectating then updateCamera() end
        end
    end)
end
