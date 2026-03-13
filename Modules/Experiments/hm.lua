-- [[ Cryptic Hub - التحكم التخاطري المطور (Telekinesis Tower FE) ]]
-- المطور: أروى (Arwa) | الوصف: رفع البلوكات وتستيفها فوق بعضها بشكل مرتب ومنع السقوط

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local isActive = false
    local connection = nil
    local capturedParts = {} 
    local capturedOrder = {} -- لتخزين الترتيب
    
    local START_HEIGHT = 15 -- بداية الارتفاع فوق الرأس
    local SCAN_RADIUS = 60 -- مسافة التقاط البلوكات (تمت زيادتها)

    local function SendRobloxNotification(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 }) end)
    end

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
        capturedOrder = {}
    end

    local function isValidPart(part)
        if not part or not part:IsA("BasePart") then return false end
        if part.Anchored then return false end 
        if part:FindFirstAncestorOfClass("Model") and part:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid") then return false end
        if part:FindFirstAncestorOfClass("Tool") or part:FindFirstAncestorOfClass("Accessory") then return false end
        return true
    end

    Tab:AddToggle("رفع وتستيف البلوكات / Telekinesis Tower", function(state)
        isActive = state
        
        if isActive then
            SendRobloxNotification("Cryptic Hub", "🏗️ تم تفعيل البرج! (البلوكات ستترتب فوق بعضها)")
            
            connection = RunService.Heartbeat:Connect(function()
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- البحث عن بلوكات جديدة
                for _, obj in pairs(workspace:GetDescendants()) do
                    if isValidPart(obj) and not capturedParts[obj] then
                        local distance = (obj.Position - root.Position).Magnitude
                        if distance <= SCAN_RADIUS then
                            
                            local origCollide = obj.CanCollide
                            obj.CanCollide = false 
                            obj.Massless = true
                            
                            local bp = Instance.new("BodyPosition")
                            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bp.P = 200000 -- قوة سحب هائلة لمنع السقوط
                            bp.D = 1500 
                            bp.Parent = obj

                            local bg = Instance.new("BodyGyro")
                            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                            bg.P = 50000
                            bg.Parent = obj

                            capturedParts[obj] = {
                                bp = bp, 
                                bg = bg, 
                                origCollide = origCollide
                            }
                            table.insert(capturedOrder, obj) -- إضافة للترتيب
                        end
                    end
                end

                -- تحريك البلوكات بنظام البرج (Stacking)
                local currentStackHeight = START_HEIGHT
                for i, part in ipairs(capturedOrder) do
                    local data = capturedParts[part]
                    if part and part.Parent and data and not part.Anchored then
                        -- حساب الموضع: كل بلوكة فوق اللي قبلها بناءً على حجمها
                        local targetPos = root.Position + Vector3.new(0, currentStackHeight, 0)
                        data.bp.Position = targetPos
                        data.bg.CFrame = root.CFrame -- جعل البلوكات تواجه نفس اتجاهك
                        
                        -- إضافة سرعة وهمية قوية جداً لإجبار السيرفر على إعطائك الملكية
                        pcall(function()
                            part.CanCollide = false
                            part.Velocity = Vector3.new(0, 30.1, 0) -- سرعة للأعلى تعاكس الجاذبية
                        end)

                        -- زيادة الارتفاع للبلوكة القادمة بناءً على حجم البلوكة الحالية
                        currentStackHeight = currentStackHeight + (part.Size.Y + 0.5)
                    else
                        -- تنظيف لو البلوكة اختفت
                        capturedParts[part] = nil
                        table.remove(capturedOrder, i)
                    end
                end
            end)
        else
            if connection then connection:Disconnect(); connection = nil end
            releaseAllParts()
            SendRobloxNotification("Cryptic Hub", "⬇️ تم إسقاط البرج.")
        end
    end)
    
    Tab:AddLine()
end
