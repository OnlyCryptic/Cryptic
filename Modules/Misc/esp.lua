-- [[ Cryptic Hub - كشف اللاعبين (ESP) مع الأسماء ]]
-- المطور: Cryptic | التحديث: تنظيف الذاكرة الذكي (Memory Leak Fix) عبر PlayerRemoving

return function(Tab, UI)
    local Players = game:GetService("Players")
    -- الجدول صار يعتمد على اللاعب لتسهيل التنظيف: espObjects[player] = {obj1, obj2}
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
            -- تنظيف أي عناصر ESP قديمة مسجلة لهذا اللاعب (لو مات وترسبن من جديد)
            if espObjects[plr] then
                for _, obj in ipairs(espObjects[plr]) do
                    if obj and obj.Parent then obj:Destroy() end
                end
            end
            espObjects[plr] = {} -- إنشاء قائمة جديدة خاصة باللاعب
            
            -- 1. إضافة الإضاءة
            if not char:FindFirstChild("CrypticESP_Highlight") then
                local h = Instance.new("Highlight", char)
                h.Name = "CrypticESP_Highlight"
                h.FillColor = Color3.fromRGB(0, 255, 150)
                table.insert(espObjects[plr], h)
            end
            
            -- 2. إضافة الاسم المتفاعل
            local head = char:WaitForChild("Head", 2) or char:WaitForChild("HumanoidRootPart", 2)
            if head and not head:FindFirstChild("CrypticESP_Name") then
                local bgui = Instance.new("BillboardGui", head)
                bgui.Name = "CrypticESP_Name"
                bgui.AlwaysOnTop = true
                bgui.ExtentsOffset = Vector3.new(0, 2.5, 0) 
                bgui.Size = UDim2.new(4, 0, 1, 0) 
                
                local textLabel = Instance.new("TextLabel", bgui)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = plr.DisplayName 
                textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextStrokeTransparency = 0 
                
                table.insert(espObjects[plr], bgui)
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

    Tab:AddToggle("كشف لاعبين / ESP", function(active)
        if active then
            for _, p in pairs(Players:GetPlayers()) do 
                trackPlayer(p) 
            end
            
            local playerAddedConn = Players.PlayerAdded:Connect(function(p)
                trackPlayer(p)
            end)
            table.insert(connections, playerAddedConn)

            -- [[ الإضافة العبقرية: تنظيف الذاكرة عند خروج اللاعب ]]
            local playerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
                if espObjects[plr] then
                    for _, obj in ipairs(espObjects[plr]) do
                        if obj and obj.Parent then obj:Destroy() end
                    end
                    espObjects[plr] = nil -- مسح اللاعب من الذاكرة نهائياً
                end
            end)
            table.insert(connections, playerRemovingConn)
            
            SendScreenNotify("Cryptic Hub", "👁️ تم تفعيل الكشف (مع التنظيف التلقائي)!")
        else
            -- إزالة الكشف عن الجميع وتنظيف الجداول بضغطة زر
            for plr, objs in pairs(espObjects) do 
                for _, obj in ipairs(objs) do
                    if obj and obj.Parent then obj:Destroy() end
                end
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
