-- [[ Cryptic Hub - هجوم الأشياء المغناطيسي (Magnetic Part Flinger) ]]
-- المطور: يامي (Yami) | الوصف: السيارات والبلوكات تلاحق الهدف وتطيره وأنت في مكانك
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

    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 4, 
            })
        end)
    end

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

    -- [[ دالة الفحص: تتأكد إن الشيء مو ماسك فيك أو في لاعب ثاني ]]
    local function isValidPart(part)
        if not part or not part:IsA("BasePart") then return false end
        if part.Anchored then return false end 
        
        -- استثناء شخصيتك أنتِ (عشان ما تطيرين معاهم)
        if lp.Character and part:IsDescendantOf(lp.Character) then return false end
        
        -- استثناء كل اللاعبين الباقين
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChildOfClass("Humanoid") then return false end
        
        return true
    end

    -- [[ 1. نظام البحث عن لاعب ]]
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

    -- [[ 2. زر تشغيل هجوم الأشياء ]]
    Tab:AddToggle("هجوم البلوكات والسيارات / Flinger", function(state)
        isActive = state
        
        if isActive then
            if not targetPlayer then
                Notify("⚠️ الرجاء تحديد لاعب أولاً!", "Please select a target first!")
                isActive = false
                return
            end

            Notify("🌪️ بدء الهجوم! الأشياء تتجه للهدف", "Attack started! Objects flying to target")
            
            connection = RunService.Heartbeat:Connect(function()
                if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                local targetRoot = targetPlayer.Character.HumanoidRootPart

                -- التقاط كل شيء غير مثبت في الماب (حتى السيارات)
                for _, obj in pairs(workspace:GetDescendants()) do
                    if isValidPart(obj) and not capturedParts[obj] then
                        
                        local origCollide = obj.CanCollide
                        local origMassless = obj.Massless
                        
                        obj.CanCollide = true 
                        obj.Massless = false -- نخليه ثقيل عشان لما يضرب الهدف يطيره بقوة
                        
                        local bp = Instance.new("BodyPosition")
                        bp.Name = "Arwa_Fling_BP"
                        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bp.P = 500000 -- قوة سحب خيالية عشان تقدر تسحب السيارات
                        bp.D = 500 
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

                -- توجيه كل الأشياء لراس الهدف
                for part, data in pairs(capturedParts) do
                    if part and part.Parent and not part.Anchored then
                        data.bp.Position = targetRoot.Position
                        -- دوران مدمر عشان يضرب الهدف من كل الجهات
                        data.bg.CFrame = data.bg.CFrame * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)))
                    else
                        capturedParts[part] = nil
                    end
                end
            end)
        else
            if connection then connection:Disconnect(); connection = nil end
            releaseAllParts()
            Notify("🛑 تم إيقاف الهجوم، الأشياء تسقط.", "Attack stopped, objects dropping.")
        end
    end)
    
    Tab:AddLine()
end
