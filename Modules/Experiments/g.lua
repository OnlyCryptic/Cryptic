-- [[ Cryptic Hub - Shrink Size (Ant Size) Only ]]

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    -- 📢 دالة الإشعارات
    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 4
            })
        end)
    end

    -- 🛠️ دالة إنشاء الزر الأساسية
    local function AddAutoOffToggle(label, callback)
        Tab.Order = Tab.Order or 0
        Tab.Order = Tab.Order + 1
        local ParentPage = Tab.Page or Tab.Container or Tab
        
        local R = Instance.new("Frame", ParentPage)
        R.LayoutOrder = Tab.Order
        R.Size = UDim2.new(0.98, 0, 0, 45)
        R.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Instance.new("UICorner", R)
        
        local B = Instance.new("TextButton", R)
        B.Size = UDim2.new(0, 45, 0, 22)
        B.Position = UDim2.new(1, -55, 0.5, -11)
        B.Text = ""
        B.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0)
        
        local Lbl = Instance.new("TextLabel", R)
        Lbl.Text = label
        Lbl.Size = UDim2.new(1, -65, 1, 0)
        Lbl.Position = UDim2.new(0, 5, 0, 0)
        Lbl.TextColor3 = Color3.new(1, 1, 1)
        Lbl.BackgroundTransparency = 1
        Lbl.TextXAlignment = Enum.TextXAlignment.Right
        Lbl.Font = Enum.Font.GothamSemibold
        Lbl.TextSize = 11
        
        local isActive = false
        local configKey = (Tab.TabName or "Tab") .. "_" .. label
        
        local function setState(state, isManual)
            isActive = state
            B.BackgroundColor3 = isActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 60)
            if UI and UI.ConfigData then UI.ConfigData[configKey] = isActive end
            pcall(callback, isActive, isManual)
        end
        
        B.MouseButton1Click:Connect(function() setState(not isActive, true) end)

        -- إطفاء تلقائي عند الموت
        local function setupDeathEvent(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then
                hum.Died:Connect(function()
                    if isActive then
                        setState(false, false)
                        Notify("⚠️ تم إرجاع حجمك بسبب موتك", "⚠️ Size reset due to death")
                    end
                end)
            end
        end

        if lp.Character then task.spawn(function() setupDeathEvent(lp.Character) end) end
        lp.CharacterAdded:Connect(setupDeathEvent)

        return { SetState = function(self, state) setState(state, false) end }
    end

    -- ==============================================================
    -- 🐜 ميزة التصغير (Shrink Size)
    -- ==============================================================
    local originalScales = {}
    local isShrunk = false

    local function SetCharacterScale(scaleMultiplier)
        local char = lp.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum then return false end

        -- القيم المسؤولة عن حجم الشخصية في R15
        local scaleNames = {"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}
        local isR15 = false

        for _, name in ipairs(scaleNames) do
            local scaleValue = hum:FindFirstChild(name)
            if scaleValue and scaleValue:IsA("NumberValue") then
                isR15 = true
                -- نحفظ حجمك الأصلي عشان نرجعك له بعدين
                if not originalScales[name] then
                    originalScales[name] = scaleValue.Value
                end

                if scaleMultiplier == 1 then
                    -- استرجاع الحجم الأصلي
                    scaleValue.Value = originalScales[name] or 1
                else
                    -- تطبيق التصغير
                    scaleValue.Value = (originalScales[name] or 1) * scaleMultiplier
                end
            end
        end

        -- إذا كانت الشخصية R6 ما راح نقدر نصغرها
        if not isR15 and scaleMultiplier ~= 1 then
            Notify("⚠️ شخصيتك R6 - الماب لا يدعم تغيير الحجم", "⚠️ R6 Character - Cannot change size")
            return false
        end
        return true
    end

    -- إنشاء زر التصغير
    local shrinkToggle
    shrinkToggle = AddAutoOffToggle("حجم النملة / Shrink Size", function(active, isManual)
        if active then
            isShrunk = true
            -- 0.3 يعني 30% من حجمك الطبيعي (تقدر تخليها 0.2 أو 0.5 براحتك)
            local success = SetCharacterScale(0.3) 
            if success then
                Notify("🐜 تم تصغير الحجم!", "🐜 Shrunk to ant size!")
            else
                -- إذا الشخصية R6 يطفي الزر من نفسه
                shrinkToggle:SetState(false) 
            end
        else
            isShrunk = false
            -- يرجعك لحجمك 100%
            SetCharacterScale(1) 
            Notify("🧍 تم استرجاع الحجم الطبيعي", "🧍 Size restored")
        end
    end)

    -- لو متت ورسبنت والزر لسه شغال، يصغرك تلقائياً
    lp.CharacterAdded:Connect(function(char)
        if isShrunk then
            task.wait(0.5) -- ننتظر الشخصية تحمل
            SetCharacterScale(0.3)
        end
    end)
end
