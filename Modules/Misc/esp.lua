-- [[ Cryptic Hub - كشف اللاعبين (ESP) مع الأسماء ]]
-- المطور: Cryptic | التحديث: إضافة أسماء حمراء تصغر من بعيد + إشعارات الشاشة

return function(Tab, UI)
    -- جدول لحفظ كل الإضافات (التحديد + الأسماء) عشان نمسحها بسهولة
    local espObjects = {}

    -- دالة إرسال الإشعارات على شاشة اللعبة مباشرة
    local function SendScreenNotify(title, text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 3 
            })
        end)
    end

    local function applyESP(plr)
        if plr == game.Players.LocalPlayer then return end
        
        pcall(function()
            local char = plr.Character or plr.CharacterAdded:Wait()
            if char then
                -- 1. إضافة الإضاءة (Highlight) للجسم
                if not char:FindFirstChild("CrypticESP_Highlight") then
                    local h = Instance.new("Highlight", char)
                    h.Name = "CrypticESP_Highlight"
                    h.FillColor = Color3.fromRGB(0, 255, 150) -- أخضر
                    table.insert(espObjects, h)
                end
                
                -- 2. إضافة الاسم (Name ESP) فوق الرأس
                local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if head and not head:FindFirstChild("CrypticESP_Name") then
                    local bgui = Instance.new("BillboardGui", head)
                    bgui.Name = "CrypticESP_Name"
                    bgui.AlwaysOnTop = true -- يظهر من خلف الجدران
                    bgui.ExtentsOffset = Vector3.new(0, 2.5, 0) -- الارتفاع فوق الرأس
                    
                    -- استخدام Scale يجعل النص يصغر تلقائياً كلما ابتعد اللاعب
                    bgui.Size = UDim2.new(4, 0, 1, 0) 
                    
                    local textLabel = Instance.new("TextLabel", bgui)
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = plr.DisplayName -- يعرض اسم العرض
                    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- لون أحمر
                    textLabel.TextScaled = true
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.TextStrokeTransparency = 0 -- حدود سوداء لتوضيح الخط
                    
                    table.insert(espObjects, bgui)
                end
            end
        end)
    end

    Tab:AddToggle("كشف اللاعبين", function(active)
        if active then
            -- تطبيق الكشف والأسماء على جميع اللاعبين
            for _, p in pairs(game.Players:GetPlayers()) do 
                applyESP(p) 
            end
            
            SendScreenNotify("Cryptic Hub", "👁️ تم تفعيل كشف اللاعبين والأسماء!")
        else
            -- إزالة الكشف والأسماء عن الجميع
            for _, obj in pairs(espObjects) do 
                if obj then obj:Destroy() end 
            end
            espObjects = {}
            
            SendScreenNotify("Cryptic Hub", "🛑 تم إيقاف كشف اللاعبين.")
        end
    end)
end
