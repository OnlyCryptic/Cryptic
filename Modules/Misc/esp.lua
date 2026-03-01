-- [[ Cryptic Hub - نظام الكشف المطور ]]
-- الميزات: إظهار الأسماء + تغيير اللون حسب المسافة (أحمر للقريب)

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local espEnabled = false
    local espData = {} -- تخزين الهالات والأسماء

    -- وظيفة إنشاء وتحديث الكشف
    local function createESP(plr)
        if plr == lp then return end
        
        local function setup(char)
            task.wait(0.5) -- انتظار تحميل الشخصية
            if not char:FindFirstChild("CrypticHighlight") then
                -- 1. إنشاء الهالة (Highlight)
                local h = Instance.new("Highlight")
                h.Name = "CrypticHighlight"
                h.Parent = char
                h.FillTransparency = 0.5
                h.OutlineTransparency = 0
                
                -- 2. إنشاء لوحة الاسم (BillboardGui)
                local bbg = Instance.new("BillboardGui")
                bbg.Name = "CrypticName"
                bbg.Size = UDim2.new(0, 200, 0, 50)
                bbg.Adornee = char:FindFirstChild("Head")
                bbg.AlwaysOnTop = true
                bbg.ExtentsOffset = Vector3.new(0, 3, 0)
                bbg.Parent = char
                
                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(1, 0, 1, 0)
                label.Text = plr.DisplayName or plr.Name
                label.TextColor3 = Color3.new(1, 1, 1)
                label.TextStrokeTransparency = 0
                label.TextScaled = true
                label.Font = Enum.Font.GothamBold
                label.Parent = bbg
                
                espData[plr] = {Highlight = h, Label = label, Gui = bbg}
            end
        end

        plr.CharacterAdded:Connect(setup)
        if plr.Character then setup(plr.Character) end
    end

    -- التبديل (Toggle) لتفعيل/إيقاف الكشف
    Tab:AddToggle("🎯 كشف اللاعبين (ESP)", function(active)
        espEnabled = active
        if active then
            for _, p in pairs(players:GetPlayers()) do createESP(p) end
            UI:Notify("✅ تم تفعيل الكشف الذكي في Cryptic Hub")
        else
            -- تنظيف شامل عند الإيقاف
            for plr, data in pairs(espData) do
                if data.Highlight then data.Highlight:Destroy() end
                if data.Gui then data.Gui:Destroy() end
            end
            espData = {}
            UI:Notify("❌ تم إيقاف الكشف")
        end
    end)

    -- حلقة التحديث المستمر للألوان والمسافات
    runService.RenderStepped:Connect(function()
        if not espEnabled then return end
        
        for plr, data in pairs(espData) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local char = plr.Character
                local dist = (lp.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                
                -- منطق الألوان حسب المسافة
                if dist < 40 then -- إذا كان اللاعب أقرب من 40 مسمار
                    data.Highlight.FillColor = Color3.fromRGB(255, 0, 0) -- أحمر خطر
                    data.Highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
                    data.Label.TextColor3 = Color3.fromRGB(255, 0, 0)
                else
                    data.Highlight.FillColor = Color3.fromRGB(0, 255, 150) -- أخضر/مينت (اللون الافتراضي لـ Cryptic)
                    data.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    data.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
                
                -- تحديث النص ليظهر الاسم والمسافة
                data.Label.Text = (plr.DisplayName or plr.Name) .. " [" .. math.floor(dist) .. "m]"
            else
                -- إذا غادر اللاعب أو مات، نظف البيانات
                if data.Highlight then data.Highlight:Destroy() end
                if data.Gui then data.Gui:Destroy() end
                espData[plr] = nil
            end
        end
    end)

    -- معالجة اللاعبين الجدد الذين ينضمون أثناء التفعيل
    players.PlayerAdded:Connect(function(p)
        if espEnabled then createESP(p) end
    end)
end
