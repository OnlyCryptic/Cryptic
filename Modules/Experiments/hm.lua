-- [[ Cryptic Hub - التحكم التخاطري المطور (Telekinesis Tower FE) ]]
-- المطور: أروى (Arwa) | الوصف: ترتيب ناعم جداً + سحب البلوكات بدون لاق + منع الاهتزاز

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local isActive = false
    local connection = nil
    local capturedParts = {} 
    local capturedOrder = {} 
    
    local START_HEIGHT = 10 -- الارتفاع المبدئي فوق رأسك
    local SCAN_RADIUS = 150 -- مسافة التقاط البلوكات
    local MAX_BLOCKS = 100 -- الحد الأقصى لمنع اللاق

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

    Tab:AddToggle("رفع وتستيف البلوكات / Telekinesis", function(state)
        isActive = state
        
        if isActive then
            SendRobloxNotification("Cryptic Hub", "🌌 تم التفعيل! (جاري تجميع وترتيب البلوكات بذكاء...)")
            
            -- 1. حلقة البحث (تعمل كل نصف ثانية لعدم التسبب بـ لاق)
            task.spawn(function()
                while isActive do
                    local char = lp.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local currentCount = #capturedOrder
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if currentCount >= MAX_BLOCKS then break end
                            
                            if isValidPart(obj) and not capturedParts[obj] then
                                local distance = (obj.Position - root.Position).Magnitude
                                if distance <= SCAN_RADIUS then
                                    local origCollide = obj.CanCollide
                                    obj.CanCollide = false 
                                    obj.Massless = true
                                    
                                    local bp = Instance.new("BodyPosition")
                                    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    bp.P = 30000 -- قوة ناعمة تمنع الاهتزاز
                                    bp.D = 800 
                                    bp.Parent = obj

                                    local bg = Instance.new("BodyGyro")
                                    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                                    bg.P = 20000
                                    bg.Parent = obj

                                    capturedParts[obj] = { bp = bp, bg = bg, origCollide = origCollide }
                                    table.insert(capturedOrder, obj)
                                    currentCount = currentCount + 1
                                end
                            end
                        end
                    end
                    task.wait(0.5) -- فحص بدون إرهاق للجهاز
                end
            end)

            -- 2. حلقة الحركة (لتحريك البرج بسلاسة تامة)
            connection = RunService.Heartbeat:Connect(function()
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local currentStackHeight = START_HEIGHT
                
                for i = #capturedOrder, 1, -1 do
                    local part = capturedOrder[i]
                    local data = capturedParts[part]
                    
                    if part and part.Parent and data and not part.Anchored then
                        -- ترتيب البلوكات فوق بعضها
                        local targetPos = root.Position + Vector3.new(0, currentStackHeight, 0)
                        data.bp.Position = targetPos
                        data.bg.CFrame = root.CFrame 
                        
                        pcall(function()
                            part.CanCollide = false
                            -- إعطاء سرعة وهمية صغيرة جداً للحفاظ على الملكية بدون الاهتزاز العنيف
                            part.Velocity = Vector3.new(0, 0.05, 0) 
                        end)

                        -- زيادة الارتفاع للبلوكة التالية بشكل دقيق
                        currentStackHeight = currentStackHeight + (part.Size.Y + 0.1)
                    else
                        -- تنظيف القائمة إذا انحذفت البلوكة من الماب
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
