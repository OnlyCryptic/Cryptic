-- [[ Cryptic Hub - Shrink Size (Aggressive Version) ]]

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
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
    -- 🐜 ميزة التصغير (Shrink Size) الإجبارية
    -- ==============================================================
    local originalScales = {}
    local isShrunk = false
    local shrinkLoop = nil

    -- دالة لتصغير الحجم وحفظ الحجم الأصلي
    local function ForceScale(multiplier)
        local char = lp.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum then return false end

        -- إذا كانت الشخصية R6، نوقف العملية فوراً
        if hum.RigType == Enum.HumanoidRigType.R6 then
            return false
        end

        local scaleNames = {"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}

        for _, name in ipairs(scaleNames) do
            local scaleValue = hum:FindFirstChild(name)
            if scaleValue and scaleValue:IsA("NumberValue") then
                -- حفظ الحجم الأساسي أول مرة فقط
                if not originalScales[name] then
                    originalScales[name] = scaleValue.Value
                end

                local targetValue = (originalScales[name] or 1) * multiplier
                -- فرض الحجم الجديد
                scaleValue.Value = targetValue
            end
        end
        return true
    end

    local shrinkToggle
    shrinkToggle = AddAutoOffToggle("حجم النملة / Shrink Size", function(active, isManual)
        if active then
            isShrunk = true
            
            -- فحص إذا كانت الشخصية تدعم التصغير (R15)
            local checkR15 = ForceScale(0.3)
            if not checkR15 then
                Notify("🚫 الماب لا يدعم التصغير (R6)", "🚫 Map doesn't support shrinking (R6)")
                shrinkToggle:SetState(false)
                return
            end

            Notify("🐜 تم تصغير الحجم بالقوة!", "🐜 Forced ant size!")

            -- لوب إجباري لتثبيت الحجم (يمنع الماب من إرجاع حجمك الطبيعي)
            if shrinkLoop then shrinkLoop:Disconnect() end
            shrinkLoop = RunService.Stepped:Connect(function()
                if isShrunk then
                    ForceScale(0.3) -- 0.3 هو نسبة التصغير
                end
            end)

        else
            -- إيقاف التصغير
            isShrunk = false
            if shrinkLoop then 
                shrinkLoop:Disconnect() 
                shrinkLoop = nil 
            end
            
            -- استرجاع الحجم الطبيعي (1.0)
            ForceScale(1)
            Notify("🧍 تم استرجاع الحجم الطبيعي", "🧍 Size restored")
        end
    end)

    -- إعادة تفعيل اللوب إذا رسبن اللاعب والزر شغال
    lp.CharacterAdded:Connect(function(char)
        if isShrunk then
            task.wait(0.5)
            if ForceScale(0.3) then
                if shrinkLoop then shrinkLoop:Disconnect() end
                shrinkLoop = RunService.Stepped:Connect(function()
                    if isShrunk then ForceScale(0.3) end
                end)
            end
        end
    end)
end
