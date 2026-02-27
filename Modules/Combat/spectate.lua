-- [[ Arwa Hub - استهداف اللاعبين (تحكم كامل) ]]
-- المطور: Arwa | إصلاح الإيم بوت، تقليد الشات، وترتيب الأزرار

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

    -- وظيفة تقليد الشات (مُصلحة لتدعم تحديثات روبلوكس الجديدة)
    local function setupMimicConnection()
        if mimicConnection then 
            mimicConnection:Disconnect() 
            mimicConnection = nil 
        end
        
        if isMimicking and selectedPlayer then
            mimicConnection = selectedPlayer.Chatted:Connect(function(msg)
                pcall(function()
                    -- دعم نظام الشات القديم
                    if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
                        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
                    -- دعم نظام الشات الجديد (تم إصلاح المسار إلى TextChannels)
                    elseif TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral") then
                        TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
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
            setupMimicConnection() 
            if isSpectating and SpectateToggle then SpectateToggle.SetState(false) end
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
            setupMimicConnection() 
        else
            selectedPlayer = nil
            UI:Notify("❌ لم يتم العثور على لاعب")
            setupMimicConnection()
        end
    end)

    Tab:AddLine()

    -- 2. ميزة الانتقال (تم نقلها لتكون الأولى فوق المراقبة)
    Tab:AddButton("🚀 انتقال إلى الهدف", function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then 
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0) 
            end
        else
            UI:Notify("حدد هدفاً أولاً!")
        end
    end)

    -- 3. ميزة المراقبة
    SpectateToggle = Tab:AddToggle("👁️ تشغيل وضع المراقبة", function(active)
        isSpectating = active
        if active and selectedPlayer then 
            camera.CameraSubject = selectedPlayer.Character.Humanoid
        else 
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lp.Character.Humanoid 
            end
        end
    end)

    Tab:AddLine()

    -- 4. ميزة الإيم بوت (مُصلحة: توجيه الشاشة والشخصية معاً)
    Tab:AddToggle("🔫 إيم بوت على الهدف (Aimbot)", function(active)
        isAimbotting = active
        UI:Notify(active and "تم تثبيت السلاح والشاشة على الهدف" or "تم إيقاف الإيم بوت")
    end)

    -- 5. ميزة الجلوس على الرأس
    Tab:AddToggle("🪑 الجلوس على رأس الهدف", function(active)
        isSitting = active
        UI:Notify(active and "أنت الآن تجلس على رأسه!" or "تم النزول")
    end)

    -- 6. ميزة تقليد الكلام (مُصلحة)
    Tab:AddToggle("💬 تقليد كلام الهدف (Mimic)", function(active)
        isMimicking = active
        setupMimicConnection()
        UI:Notify(active and "أي شيء سيكتبه، ستكتبه أنت تلقائياً!" or "تم إيقاف تقليد الكلام")
    end)

    -- حلقات التحديث المستمرة
    task.spawn(function()
        RunService.RenderStepped:Connect(function()
            -- تحديث المراقبة
            if isSpectating and selectedPlayer and selectedPlayer.Character then 
                camera.CameraSubject = selectedPlayer.Character:FindFirstChild("Humanoid") or lp.Character.Humanoid
            end
            
            -- تحديث الإيم بوت (التحكم في الكاميرا وحركة الشخصية)
            if isAimbotting and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Head") then
                local targetPos = selectedPlayer.Character.Head.Position
                
                -- توجيه الكاميرا (شاشتك) نحو الهدف
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
                
                -- توجيه شخصيتك نحو الهدف (مع الحفاظ على استقامة الجسم)
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    local root = lp.Character.HumanoidRootPart
                    local lookPos = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
                    root.CFrame = CFrame.lookAt(root.Position, lookPos)
                end
            end
        end)
    end)

    task.spawn(function()
        RunService.Heartbeat:Connect(function()
            if isSitting and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Head") then
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    lp.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.Head.CFrame * CFrame.new(0, 1.5, 0)
                    if lp.Character:FindFirstChild("Humanoid") then
                        lp.Character.Humanoid.Sit = true
                    end
                end
            end
        end)
    end)
end
