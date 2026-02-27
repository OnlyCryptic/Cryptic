-- [[ Cryptic Hub - ميزة مراقبة وانتقال اللاعبين الذكية ]]
-- المطور: Arwa | التحديث: البحث عند إغلاق الكيبورد + أقرب يوزر
-- تاريخ التعديل: 2026/02/27

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

    -- 1. خانة البحث الذكية
    local SearchInput
    SearchInput = Tab:AddInput("البحث عن لاعب", "اكتب بداية اليوزر ثم أغلق الكيبورد...", function(txt)
        -- نترك المعالجة لحدث FocusLost لضمان إغلاق الكيبورد تماماً
    end)

    -- منطق كشف إغلاق الكيبورد والبحث عن أقرب يوزر
    task.spawn(function()
        -- البحث عن عنصر الـ TextBox الحقيقي داخل الواجهة
        local screenGui = game:GetService("CoreGui"):WaitForChild("ArwaHub_Final_V2_3", 10)
        if not screenGui then return end
        
        local textBox = screenGui:FindFirstChild("TextBox", true)
        if textBox then
            textBox.FocusLost:Connect(function(enterPressed)
                local txt = textBox.Text
                if txt == "" then
                    selectedPlayer = nil
                    if isSpectating then _G.SpectateToggleHandle.SetState(false) end
                    return
                end

                local bestMatch = nil
                local search = txt:lower()

                -- البحث عن أقرب لاعب يبدأ يوزره بنفس الحروف
                for _, p in pairs(players:GetPlayers()) do
                    if p ~= lp then
                        local pName = p.Name:lower()
                        local pDisplay = p.DisplayName:lower()
                        
                        -- التحقق من بداية اليوزر أو اسم العرض
                        if string.sub(pName, 1, #search) == search or string.sub(pDisplay, 1, #search) == search then
                            -- اختيار أول وأقرب تطابق
                            bestMatch = p
                            break 
                        end
                    end
                end

                if bestMatch then
                    selectedPlayer = bestMatch
                    SearchInput.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
                    UI:Notify("تم تحديد: " .. bestMatch.DisplayName)
                else
                    selectedPlayer = nil
                    UI:Notify("لم يتم العثور على لاعب يبدأ بـ: " .. txt)
                    if isSpectating then _G.SpectateToggleHandle.SetState(false) end
                end
            end)
        end
    end)

    -- خط فاصل للتنظيم تحت الـ ESP
    Tab:AddLine()

    -- 2. زر تشغيل المراقبة
    _G.SpectateToggleHandle = Tab:AddToggle("تشغيل وضع المراقبة", function(active)
        isSpectating = active
        if active then
            if selectedPlayer then
                updateCamera()
                UI:Notify("تراقب الآن تحركات " .. selectedPlayer.DisplayName)
            else
                UI:Notify("اكتب يوزر اللاعب أولاً!")
                task.spawn(function() _G.SpectateToggleHandle.SetState(false) end)
            end
        else
            updateCamera()
            UI:Notify("تم العودة لكاميرا شخصيتك")
        end
    end)

    -- 3. زر الانتقال السريع للاعب
    Tab:AddButton("انتقال إلى اللاعب", function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                UI:Notify("تم الانتقال بنجاح إلى " .. selectedPlayer.DisplayName)
            end
        else
            UI:Notify("الرجاء تحديد لاعب أولاً!")
        end
    end)

    -- نظام الإيقاف التلقائي عند خروج اللاعب
    players.PlayerRemoving:Connect(function(p)
        if selectedPlayer and p == selectedPlayer then
            selectedPlayer = nil
            if isSpectating then _G.SpectateToggleHandle.SetState(false) end
            SearchInput.SetText("")
            UI:Notify("اللاعب غادر السيرفر، تم إيقاف المراقبة")
        end
    end)

    -- تحديث الكاميرا المستمر
    task.spawn(function()
        while task.wait(0.5) do
            if isSpectating then updateCamera() end
        end
    end)
end
