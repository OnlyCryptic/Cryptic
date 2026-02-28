-- [[ Arwa Hub - استهداف اللاعبين (الإصدار الشامل) ]]
-- المطور: Arwa | الميزات: مراقبة، إيم بوت مستقر، تقليد شات، جلوس آمن

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

    -- وظيفة تقليد الشات (تدعم النص الخام والنظام الجديد والقديم)
    local function setupMimicConnection()
        if mimicConnection then 
            mimicConnection:Disconnect() 
            mimicConnection = nil 
        end
        
        if isMimicking and selectedPlayer then
            mimicConnection = selectedPlayer.Chatted:Connect(function(msg)
                local rawMsg = tostring(msg) -- جلب النص الأصلي كما هو
                pcall(function()
                    -- دعم نظام الشات الجديد (TextChannels)
                    if TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral") then
                        TextChatService.TextChannels.RBXGeneral:SendAsync(rawMsg)
                    -- دعم نظام الشات القديم (SayMessageRequest)
                    elseif ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
                        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(rawMsg, "All")
                    end
                end)
            end)
        end
    end

    -- 1. البحث عن اللاعب
    local InputField = Tab:AddInput("البحث عن لاعب", "اكتب بداية اليوزر وأغلق الكيبورد...", function(txt) end)

    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then 
            selectedPlayer = nil
            setupMimicConnection() 
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

    -- 2. الانتقال إلى الهدف (فوق المراقبة كما طلبتِ)
    Tab:AddButton("🚀 انتقال إلى الهدف", function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then 
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0) 
            end
        else
            UI:Notify("حدد هدفاً أولاً!")
        end
    end)

    -- 3. المراقبة
    Tab:AddToggle("👁️ تشغيل وضع المراقبة", function(active)
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

    -- 4. الإيم بوت المستقر (يسمح بالقفز ولا يعلق)
    Tab:AddToggle("🔫 إيم بوت على الهدف (Aimbot)", function(active)
        isAimbotting = active
        if not active and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local gyro = lp.Character.HumanoidRootPart:FindFirstChild("AimbotGyro")
            if gyro then gyro:Destroy() end -- تنظيف عند الإيقاف
        end
    end)

    -- 5. الجلوس على الرأس (آمن من الموت والتطيير)
    Tab:AddToggle("🪑 الجلوس على رأس الهدف", function(active)
        isSitting = active
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.Sit = active -- الجلوس مرة واحدة لمنع الموت
        end
    end)

    -- 6. تقليد الكلام
    Tab:AddToggle("💬 تقليد كلام الهدف (Mimic)", function(active)
        isMimicking = active
        setupMimicConnection()
    end)

    -- ================= الحلقات المستمرة (Loops) =================

    -- حلقة الكاميرا والإيم بوت
    RunService.RenderStepped:Connect(function()
        if isSpectating and selectedPlayer and selectedPlayer.Character then 
            camera.CameraSubject = selectedPlayer.Character:FindFirstChild("Humanoid") or lp.Character.Humanoid
        end
        
        if isAimbotting and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Head") then
            local targetPos = selectedPlayer.Character.Head.Position
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
            
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local root = lp.Character.HumanoidRootPart
                local gyro = root:FindFirstChild("AimbotGyro") or Instance.new("BodyGyro", root)
                gyro.Name = "AimbotGyro"
                gyro.MaxTorque = Vector3.new(0, math.huge, 0) -- يسمح بالقفز بحرية
                gyro.P = 50000 
                gyro.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
            end
        end
    end)

    -- حلقة مضاد التطيير (Anti-Fling) والجلوس الآمن
    RunService.Stepped:Connect(function()
        if isSitting and lp.Character then
            -- إلغاء التصادم لمنع التطيير
            for _, otherPlayer in pairs(players:GetPlayers()) do
                if otherPlayer ~= lp and otherPlayer.Character then
                    for _, part in pairs(otherPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if isSitting and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Head") then
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local root = lp.Character.HumanoidRootPart
                root.Velocity = Vector3.new(0,0,0) -- منع الموت بسبب السرعة المتراكمة
                root.CFrame = selectedPlayer.Character.Head.CFrame * CFrame.new(0, 2.2, 0) -- مسافة آمنة
            end
        end
    end)
end
