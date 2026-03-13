-- [[ Cryptic Hub - التحكم التخاطري بالبلوكات (Telekinesis Aura FE) ]]
-- المطور: أروى (Arwa) | الوصف: رفع البلوكات للأبد وتتبع اللاعب في كل مكان بدون أخطاء تصادم

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local isActive = false
    local connection = nil
    local capturedParts = {} 
    
    local LEVITATION_HEIGHT = 16 -- الارتفاع فوق الرأس
    local SCAN_RADIUS = 40 -- مسافة التقاط البلوكات

    -- دالة الإشعارات
    local function SendRobloxNotification(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 }) end)
    end

    -- دالة التنظيف (لإسقاط البلوكات واسترجاع طبيعتها)
    local function releaseAllParts()
        for part, data in pairs(capturedParts) do
            if part and part.Parent then
                if data.bp then data.bp:Destroy() end
                if data.bg then data.bg:Destroy() end
                pcall(function() 
                    part.Massless = false 
                    part.CanCollide = data.origCollide
                end)
            end
        end
        capturedParts = {}
    end

    -- دالة فحص البلوكات
    local function isValidPart(part)
        if not part or not part:IsA("BasePart") then return false end
        if part.Anchored then return false end 
        
        -- 1. منع التقاط أجزاء الشخصيات الأساسية
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChildOfClass("Humanoid") then return false end
        
        -- 2. (حل المشكلة الثانية) منع التقاط الأدوات والإكسسوارات لمنع تقليتش اللاعبين
        if part:FindFirstAncestorOfClass("Tool") or part:FindFirstAncestorOfClass("Accessory") then return false end
        
        return true
    end

    Tab:AddToggle("رفع بلوكات غ.ير مثبته / Telekinesis", function(state)
        isActive = state
        
        if isActive then
            SendRobloxNotification("Cryptic Hub", "🌌 الهالة مفعلة! (البلوكات ستتبعك ولن تفلت منك أبداً)")
            
            connection = RunService.Heartbeat:Connect(function()
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                for _, obj in pairs(workspace:GetDescendants()) do
                    if isValidPart(obj) then
                        local distance = (obj.Position - root.Position).Magnitude
                        if distance <= SCAN_RADIUS then
                            if not capturedParts[obj] then
                                
                                local origCollide = obj.CanCollide
                                obj.CanCollide = false 
                                obj.Massless = true
                                
                                local bp = Instance.new("BodyPosition")
                                bp.Name = "Cryptic_Telekinesis_BP"
                                bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bp.P = 100000 
                                bp.D = 1000 
                                bp.Parent = obj

                                local bg = Instance.new("BodyGyro")
                                bg.Name = "Cryptic_Telekinesis_BG"
                                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                                bg.Parent = obj

                                local randomOffset = Vector3.new(
                                    math.random(-15, 15), 
                                    math.random(-3, 8),   
                                    math.random(-15, 15)  
                                )

                                capturedParts[obj] = {
                                    bp = bp, 
                                    bg = bg, 
                                    offset = randomOffset,
                                    origCollide = origCollide
                                }
                            end
                        end
                    end
                end

                for part, data in pairs(capturedParts) do
                    if part and part.Parent and not part.Anchored then
                        data.bp.Position = root.Position + Vector3.new(0, LEVITATION_HEIGHT, 0) + data.offset
                        data.bg.CFrame = root.CFrame * CFrame.Angles(math.rad(math.random(-15, 15)), tick() % 360, math.rad(math.random(-15, 15)))
                        
                        -- 3. (حل المشكلة الأولى) إجبار اللعبة على إبقاء البلوكات لك ومنع سقوطها
                        pcall(function()
                            part.CanCollide = false
                            -- سرعة وهمية صغيرة جداً تمنع نظام روبلوكس من نقل ملكية البلوكة للاعب آخر
                            part.Velocity = Vector3.new(0, 0.1, 0)
                        end)
                    else
                        capturedParts[part] = nil
                    end
                end
            end)
        else
            if connection then connection:Disconnect(); connection = nil end
            releaseAllParts()
            SendRobloxNotification("Cryptic Hub", "⬇️ تم إيقاف الهالة، البلوكات تسقط الآن.")
        end
    end)
    
    Tab:AddLine()
end
