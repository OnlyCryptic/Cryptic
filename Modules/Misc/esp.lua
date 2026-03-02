-- [[ Cryptic Hub - كشف اللاعبين (ESP) مع الأسماء والمسافة ]]
-- المطور: Cryptic | التحديث: إضافة المسافة [Distance] + وضوح لا نهائي للاسم من بعيد

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    
    -- الجدول صار يحفظ كل شيء بأسماء مرتبة عشان نقدر نحدث النص
    local espObjects = {} 
    local connections = {}

    -- دالة إرسال الإشعارات
    local function SendScreenNotify(title, text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title, Text = text, Duration = 3 
            })
        end)
    end

    local function applyESP(char, plr)
        if plr == Players.LocalPlayer then return end
        
        pcall(function()
            -- تنظيف أي عناصر قديمة مسجلة لهذا اللاعب
            if espObjects[plr] then
                if espObjects[plr].Highlight then espObjects[plr].Highlight:Destroy() end
                if espObjects[plr].Billboard then espObjects[plr].Billboard:Destroy() end
            end
            espObjects[plr] = {} 
            
            -- 1. إضافة الإضاءة (Highlight)
            if not char:FindFirstChild("CrypticESP_Highlight") then
                local h = Instance.new("Highlight", char)
                h.Name = "CrypticESP_Highlight"
                h.FillColor = Color3.fromRGB(0, 255, 150)
                espObjects[plr].Highlight = h
            end
            
            -- 2. إضافة الاسم والمسافة (بدون ما يختفي من بعيد)
            local head = char:WaitForChild("Head", 2) or char:WaitForChild("HumanoidRootPart", 2)
            if head and not head:FindFirstChild("CrypticESP_Name") then
                local bgui = Instance.new("BillboardGui", head)
                bgui.Name = "CrypticESP_Name"
                bgui.AlwaysOnTop = true
                bgui.MaxDistance = math.huge -- لا يختفي أبداً مهما ابتعد
                bgui.ExtentsOffset = Vector3.new(0, 3, 0) 
                
                -- استخدام (Offset) بدل (Scale) عشان يظل الحجم ثابت على الشاشة دائماً
                bgui.Size = UDim2.new(0, 200, 0, 50) 
                
                local textLabel = Instance.new("TextLabel", bgui)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = plr.DisplayName .. " [0]" -- النص المبدئي
                textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                textLabel.TextScaled = false -- إيقاف التصغير التلقائي
                textLabel.TextSize = 14 -- حجم خط ثابت وواضح جداً
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextStrokeTransparency = 0 -- حدود سوداء للوضوح
                
                espObjects[plr].Billboard = bgui
                espObjects[plr].TextLabel = textLabel -- حفظ النص عشان نحدث المسافة
            end
        end)
    end

    local function trackPlayer(plr)
        if plr.Character then
            applyESP(plr.Character, plr)
        end
        
        local charAddedConn = plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            applyESP(char, plr)
        end)
        table.insert(connections, charAddedConn)
    end

    Tab:AddToggle("كشف اللاعبين", function(active)
        if active then
            -- تطبيق الكشف على الجميع
            for _, p in pairs(Players:GetPlayers()) do 
                trackPlayer(p) 
            end
            
            -- مراقبة دخول اللاعبين الجدد
            local playerAddedConn = Players.PlayerAdded:Connect(function(p)
                trackPlayer(p)
            end)
            table.insert(connections, playerAddedConn)

            -- تنظيف عند الخروج
            local playerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
                if espObjects[plr] then
                    if espObjects[plr].Highlight then espObjects[plr].Highlight:Destroy() end
                    if espObjects[plr].Billboard then espObjects[plr].Billboard:Destroy() end
                    espObjects[plr] = nil 
                end
            end)
            table.insert(connections, playerRemovingConn)
            
            -- [[ المحرك الجديد: تحديث المسافة بشكل حي ] ]
            local renderConn = RunService.RenderStepped:Connect(function()
                local lpChar = Players.LocalPlayer.Character
                local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
                
                for plr, data in pairs(espObjects) do
                    if plr.Character and data.TextLabel then
                        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        if lpRoot and targetRoot then
                            -- حساب المسافة بينك وبين اللاعب
                            local dist = math.floor((lpRoot.Position - targetRoot.Position).Magnitude)
                            -- تحديث النص ليصبح: الاسم [المسافة]
                            data.TextLabel.Text = string.format("%s [%d]", plr.DisplayName, dist)
                        end
                    end
                end
            end)
            table.insert(connections, renderConn)

            SendScreenNotify("Cryptic Hub", "👁️ تم تفعيل الكشف مع المسافات!")
        else
            -- تنظيف كل شيء عند الإيقاف
            for plr, data in pairs(espObjects) do 
                if data.Highlight then data.Highlight:Destroy() end
                if data.Billboard then data.Billboard:Destroy() end
            end
            espObjects = {}
            
            for _, conn in pairs(connections) do
                if conn then conn:Disconnect() end
            end
            connections = {}
            
            SendScreenNotify("Cryptic Hub", "🛑 تم إيقاف كشف اللاعبين.")
        end
    end)
end
