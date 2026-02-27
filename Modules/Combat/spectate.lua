-- [[ Arwa Hub - استهداف اللاعبين (تحكم كامل) ]]
-- المطور: Arwa | الميزات: مراقبة، إيم بوت، تقليد الشات، جلوس على الرأس

return function(Tab, UI)
    local players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TextChatService = game:GetService("TextChatService")
    
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    local selectedPlayer = nil
    
    -- متغيرات حالة الميزات
    local isSpectating = false
    local isAimbotting = false
    local isSitting = false
    local isMimicking = false
    local mimicConnection = nil

    local SpectateToggle

    -- وظيفة ضبط اتصال تقليد الشات (Chat Mimic)
    local function setupMimicConnection()
        if mimicConnection then 
            mimicConnection:Disconnect() 
            mimicConnection = nil 
        end
        
        if isMimicking and selectedPlayer then
            mimicConnection = selectedPlayer.Chatted:Connect(function(msg)
                pcall(function()
                    -- دعم نظام الشات القديم (Legacy Chat)
                    if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
                        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
                    -- دعم نظام الشات الجديد (TextChatService)
                    elseif TextChatService.ChatChannels:FindFirstChild("RBXGeneral") then
                        TextChatService.ChatChannels.RBXGeneral:SendAsync(msg)
                    end
                end)
            end)
        end
    end

    -- 1. خانة البحث عن اللاعب
    local InputField = Tab:AddInput("البحث عن لاعب", "اكتب بداية اليوزر وأغلق الكيبورد...", function(txt) end)

    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then 
            selectedPlayer = nil
            setupMimicConnection() -- إعادة ضبط الشات
            return 
        end

        local bestMatch = nil
        local search = txt:lower()

        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p; break 
            end
        end

        if bestMatch then
            selectedPlayer = bestMatch
            InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
            UI:Notify("🎯 تم تحديد الهدف: " .. bestMatch.DisplayName)
            setupMimicConnection() -- تشغيل التقليد فوراً إذا كان الزر مفعلاً
        else
            selectedPlayer = nil
            UI:Notify("❌ لم يتم العثور على لاعب")
            setupMimicConnection()
        end
    end)

    Tab:AddLine()

    -- 2. ميزة المراقبة (Spectate)
    SpectateToggle = Tab:AddToggle("👁️ تشغيل وضع المراقبة", function(active)
        isSpectating = active
        if active and selectedPlayer then 
            camera.CameraSubject = selectedPlayer.Character.Humanoid
        else 
            camera.CameraSubject = lp.Character.Humanoid 
        end
    end)

    -- 3. ميزة الانتقال (Teleport)
    Tab:AddButton("🚀 انتقال إلى الهدف", function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then 
            lp.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0) 
        else
            UI:Notify("حدد هدفاً أولاً!")
        end
    end)

    Tab:AddLine()

    -- 4. ميزة الإيم بوت (Target Aimbot)
    Tab:AddToggle("🔫 إيم بوت على الهدف (Aimbot)", function(active)
        isAimbotting = active
        UI:Notify(active and "تم تثبيت السلاح على الهدف" or "تم إيقاف الإيم بوت")
    end)

    -- 5. ميزة الجلوس على الرأس (Sit on Head)
    Tab:AddToggle("🪑 الجلوس على رأس الهدف", function(active)
        isSitting = active
        UI:Notify(active and "أنت الآن تجلس على رأسه!" or "تم النزول")
    end)

    -- 6. ميزة تقليد الكلام (Chat Mimic)
    Tab:AddToggle("💬 تقليد كلام الهدف (Mimic)", function(active)
        isMimicking = active
        setupMimicConnection()
        UI:Notify(active and "أي شيء سيكتبه، ستكتبه أنت تلقائياً!" or "تم إيقاف تقليد الكلام")
    end)

    -- حلقات التحديث المستمرة (Loops) للميزات
    task.spawn(function()
        -- نستخدم RenderStepped لسلاسة الكاميرا والإيم بوت
        RunService.RenderStepped:Connect(function()
            -- تحديث المراقبة
            if isSpectating and selectedPlayer and selectedPlayer.Character then 
                camera.CameraSubject = selectedPlayer.Character:FindFirstChild("Humanoid") or lp.Character.Humanoid
            end
            
            -- تحديث الإيم بوت
            if isAimbotting and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Head") then
                -- توجيه الكاميرا مباشرة نحو رأس الهدف
                camera.CFrame = CFrame.new(camera.CFrame.Position, selectedPlayer.Character.Head.Position)
            end
        end)
    end)

    task.spawn(function()
        -- نستخدم Heartbeat لحركة اللاعب الفيزيائية (الجلوس على الرأس)
        RunService.Heartbeat:Connect(function()
            if isSitting and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Head") then
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    -- النقل المستمر فوق رأس اللاعب بمسافة 1.5
                    lp.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.Head.CFrame * CFrame.new(0, 1.5, 0)
                    
                    -- جعل شخصيتك في وضعية الجلوس (اختياري لزيادة الواقعية)
                    if lp.Character:FindFirstChild("Humanoid") then
                        lp.Character.Humanoid.Sit = true
                    end
                end
            end
        end)
    end)
end
