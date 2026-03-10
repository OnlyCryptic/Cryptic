-- [[ Cryptic Hub - هجوم الأشياء المغناطيسي (Magnetic Part Flinger) ]]
-- المطور: يامي (Yami) | الوصف: سحب البلوكات ولصقها بالهدف للطرد
-- القسم: تجارب (Experiments)

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    
    local targetPlayer = nil
    local isActive = false
    local connection = nil
    local capturedParts = {} 

    -- [[ دالة إشعارات روبلوكس الرسمية (مزدوجة اللغة) ]]
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 4, 
            })
        end)
    end

    -- [[ دالة التنظيف وإسقاط البلوكات ]]
    local function releaseAllParts()
        for part, data in pairs(capturedParts) do
            if part and part.Parent then
                if data.bp then data.bp:Destroy() end
                if data.bg then data.bg:Destroy() end
                pcall(function() 
                    part.CanCollide = data.origCollide
                    part.Massless = data.origMassless
                end)
            end
        end
        capturedParts = {}
    end

    -- [[ دالة فحص البلوكات (لاستبعاد اللاعبين والماب المثبت) ]]
    local function isValidPart(part)
        if not part or not part:IsA("BasePart") then return false end
        if part.Anchored then return false end 
        
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChildOfClass("Humanoid") then return false end
        
        return true
    end

    -- [[ 1. نظام البحث عن لاعب (المطور) ]]
    local InputField = Tab:AddInput("تحديد لاعب الهدف / Target Player", "اكتب بداية اليوزر... / Type username start...", function(txt) end)

    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then 
            targetPlayer = nil
            return 
        end

        local bestMatch = nil
        local search = txt:lower()

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p
                break 
            end
        end

        if bestMatch then
            targetPlayer = bestMatch
            InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
            Notify("🎯 تم تحديد الهدف: " .. bestMatch.DisplayName, "Target selected: " .. bestMatch.DisplayName)
        else
            targetPlayer = nil
            Notify("❌ لم يتم العثور على لاعب بهذا الاسم!", "Player not found!")
        end
    end)

    -- [[ 2. زر تشغيل الهجوم المغناطيسي ]]
    Tab:AddToggle("هجوم البلوكات / Magnetic Flinger", function(state)
        isActive = state
        
        if isActive then
            if not targetPlayer then
                Notify("⚠️ الرجاء تحديد لاعب أولاً!", "Please select a target first!")
                -- إرجاع الزر لحالة الإيقاف لأنه لا يوجد هدف
                isActive = false
                return
            end

            Notify("🌪️ بدء الهجوم! البلوكات تلاحق الهدف", "Attack started! Parts tracking target")
            
            connection = RunService.Heartbeat:Connect(function()
                -- التأكد من وجود الهدف وشخصيته
                if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                local targetRoot = targetPlayer.Character.HumanoidRootPart

                -- التقاط البلوكات في الماب
                for _, obj in pairs(workspace:GetDescendants()) do
                    if isValidPart(obj) and not capturedParts[obj] then
                        
                        -- حفظ الحالة الأصلية
                        local origCollide = obj.CanCollide
                        local origMassless = obj.Massless
                        
                        -- يجب أن يكون التصادم مفعلاً لضرب الهدف وطيرانه
                        obj.CanCollide = true 
                        obj.Massless = false
                        
                        local bp = Instance.new("BodyPosition")
                        bp.Name = "Arwa_Fling_BP"
                        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bp.P = 150000 -- قوة سحب هائلة
                        bp.D = 500 -- اندفاع سريع
                        bp.Parent = obj

                        local bg = Instance.new("BodyGyro")
                        bg.Name = "Arwa_Fling_BG"
                        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        bg.Parent = obj

                        capturedParts[obj] = {
                            bp = bp, 
                            bg = bg, 
                            origCollide = origCollide,
                            origMassless = origMassless
                        }
                    end
                end

                -- تحديث حركة البلوكات لتلصق بالهدف وتدور
                for part, data in pairs(capturedParts) do
                    if part and part.Parent and not part.Anchored then
                        -- دمج موقع البلوكة داخل جسد الهدف مباشرة
                        data.bp.Position = targetRoot.Position
                        -- دوران مجنون ومستمر لإنشاء غليتش الطيران
                        data.bg.CFrame = data.bg.CFrame * CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)))
                    else
                        -- تنظيف البلوكة إذا تدمرت أو تم تثبيتها
                        capturedParts[part] = nil
                    end
                end
            end)
        else
            if connection then connection:Disconnect(); connection = nil end
            releaseAllParts()
            Notify("🛑 تم إيقاف الهجوم، البلوكات تسقط.", "Attack stopped, parts dropping.")
        end
    end)
    
    Tab:AddLine()
end
