-- [[ Cryptic Hub - ميزة مراقبة وانتقال اللاعبين ]]
-- المطور: Arwa | نسخة: البحث الكامل والتحكم المباشر
-- تاريخ التعديل: 2026/02/27

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

    -- 1. خانة البحث (لا تحدد إلا بعد انتهاء الكتابة)
    local SearchInput
    SearchInput = Tab:AddInput("البحث عن لاعب", "اكتب اليوزر واضغط Enter...", function(txt)
        -- نترك المعالجة لحدث FocusLost لضمان انتهاء الكتابة
    end)

    -- تعديل منطق الإدخال ليعمل عند انتهاء الكتابة فقط
    task.spawn(function()
        -- ننتظر تحميل صندوق النص
        repeat task.wait() until SearchInput
        
        -- جلب العنصر الحقيقي من الواجهة (TextBox)
        -- ملاحظة: هذا يتطلب الوصول المباشر لحدث FocusLost
        local textBox = game:GetService("CoreGui").ArwaHub_Final_V2_3.Main.Content:FindFirstChild("ScrollingFrame", true):FindFirstChild("TextBox", true)
        
        if textBox then
            textBox.FocusLost:Connect(function(enterPressed)
                if not enterPressed then return end
                local txt = textBox.Text
                
                if txt == "" then
                    selectedPlayer = nil
                    UI:Notify("تم مسح البحث")
                    return
                end

                local found = nil
                for _, p in pairs(players:GetPlayers()) do
                    if p ~= lp then
                        local name = p.Name:lower()
                        local search = txt:lower()
                        -- البحث في بداية اليوزر (Prefix Search)
                        if string.sub(name, 1, #search) == search then
                            found = p
                            break
                        end
                    end
                end

                if found then
                    selectedPlayer = found
                    SearchInput.SetText(found.DisplayName .. " (@" .. found.Name .. ")")
                    UI:Notify("تم تحديد الهدف: " .. found.DisplayName)
                else
                    selectedPlayer = nil
                    UI:Notify("لم يتم العثور على لاعب يبدأ بهذا الاسم")
                end
            end)
        end
    end)

    -- خط فاصل للتنظيم
    Tab:AddLine()

    -- 2. زر تشغيل المراقبة
    local SpectateToggle
    SpectateToggle = Tab:AddToggle("تشغيل وضع المراقبة", function(active)
        isSpectating = active
        if active then
            if selectedPlayer then
                updateCamera()
            else
                UI:Notify("حدد لاعباً أولاً!")
                task.spawn(function() SpectateToggle.SetState(false) end)
            end
        else
            updateCamera()
        end
    end)

    -- 3. زر الانتقال للاعب (Teleport)
    Tab:AddButton("انتقال إلى اللاعب المختار", function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                -- الانتقال لموقع اللاعب مع رفعة بسيطة لتجنب التعليق
                lp.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                UI:Notify("تم الانتقال لـ " .. selectedPlayer.DisplayName)
            end
        else
            UI:Notify("اللاعب غير موجود أو لم يتم تحديده!")
        end
    end)

    -- تتبع خروج اللاعب المختار
    players.PlayerRemoving:Connect(function(p)
        if selectedPlayer and p == selectedPlayer then
            selectedPlayer = nil
            if isSpectating then SpectateToggle.SetState(false) end
            UI:Notify("اللاعب غادر السيرفر")
        end
    end)

    -- تكرار التحديث لضمان بقاء الكاميرا على الهدف
    task.spawn(function()
        while task.wait(0.5) do
            if isSpectating then updateCamera() end
        end
    end)
end
