-- [[ Cryptic Hub - التحكم التخاطري المطور (Telekinesis Tower FE) ]]
-- المطور: أروى (Arwa) | الوصف: فحص بدون لاق + منع الاهتزاز + التقاط عدد هائل من البلوكات

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local isActive = false
    local connection = nil
    local scanThread = nil
    local capturedParts = {} 
    local capturedOrder = {} 
    
    local START_HEIGHT = 10 -- الارتفاع المبدئي فوق رأسك
    local SCAN_RADIUS = 250 -- تم توسيع الدائرة بشكل هائل لتلتقط بلوكات من بعيد
    local MAX_BLOCKS = 150 -- الحد الأقصى للبلوكات في البرج (لمنع انهيار اللعبة)

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
            SendRobloxNotification("Cryptic Hub", "🌌 تم التفعيل! (بدون لاق، وسيلتقط كل البلوكات حولك)")
            
            -- 1. حلقة الفحص (كل ثانية مرة واحدة لمنع الاهتزاز واللاق نهائياً)
            scanThread = task.spawn(function()
                while isActive do
                    local char = lp.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local currentCount = #capturedOrder
                        
                        -- استخدام تقنية الفحص المكاني (سريعة جداً ولا تسبب لاق)
                        local overlapParams = OverlapParams.new()
                        overlapParams.FilterType = Enum.RaycastFilterType.Exclude
                        overlapParams.FilterDescendantsInstances = {char}
                        
                        local partsInRadius = workspace:GetPartBoundsInRadius(root.Position, SCAN_RADIUS, overlapParams)
                        
                        for _, obj in ipairs(partsInRadius) do
                            if currentCount >= MAX_BLOCKS then break end
                            
                            if isValidPart(obj) and not capturedParts[obj] then
                                local origCollide = obj.CanCollide
                                obj.CanCollide = false 
                                obj.Massless = true
                                
                                local bp = Instance.new("BodyPosition")
                                bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bp.P = 50000 -- قوة ناعمة تمنع اهتزاز البلوكة
                                bp.D = 1000 
                                bp.Parent = obj

                                local bg = Instance.new("BodyGyro")
                                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                                bg.P = 10000
                                bg.Parent = obj

                                capturedParts[obj] = {
                                    bp = bp, 
                                    bg = bg, 
                                    origCollide = origCollide
                                }
                                table.insert(capturedOrder, obj)
                                currentCount = currentCount + 1
                            end
                        end
                    end
                    task.wait(1) -- فحص ذكي كل ثانية فقط
                end
            end)

            -- 2. حلقة الحركة (تحديث المواقع)
            -- نستخدم Stepped بدلاً من Heartbeat لأنها تلغي التصادم قبل محرك الفيزياء، مما ينهي الاهتزاز تماماً
            connection = RunService.Stepped:Connect(function()
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local currentStackHeight = START_HEIGHT
                
                -- التحديث من الأسفل للأعلى
                for i = #capturedOrder, 1, -1 do
                    local part = capturedOrder[i]
                    local data = capturedParts[part]
                    
                    if part and part.Parent and data and not part.Anchored then
                        -- حساب مكان البلوكة فوق اللي تحتها
                        local targetPos = root.Position + Vector3.new(0, currentStackHeight, 0)
                        data.bp.Position = targetPos
                        data.bg.CFrame = root.CFrame 
                        
                        pcall(function()
                            part.CanCollide = false
                            -- استخدام سرعة دورانية بدلاً من سرعة الدفع للحفاظ على ملكية البلوكة دون اهتزازها
                            part.RotVelocity = Vector3.new(50, 0, 50) 
                        end)

                        -- رفع المساحة للبلوكة التالية
                        currentStackHeight = currentStackHeight + (part.Size.Y + 0.2)
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
