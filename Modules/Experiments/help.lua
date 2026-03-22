-- [[ Cryptic Hub - حماية من التطيير المتقدمة (Anti-Fling V2.0) ]]
-- الوصف: رادار لحظي يلقط القطع السريعة والتي تدور بشدة وينفيها قبل الاصطدام

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer

    local protectionActive = false
    local protectionLoop = nil
    local addedConnection = nil
    local removingConnection = nil
    
    -- جدول لتتبع القطع غير المثبتة لحظياً
    local trackedParts = {}

    -- دالة الإشعارات
    local function Notify(arText, enText)
        pcall(function() StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = arText .. "\n" .. enText, Duration = 3}) end)
    end

    -- ==========================================
    -- فلتر الأمان: دقيق جداً لالتقاط الدوران والسرعة الوهمية
    -- ==========================================
    local function isDangerousPart(part)
        if not part or not part.Parent then return false end
        if not part:IsA("BasePart") or part.Anchored or part.Transparency == 1 then return false end
        
        -- تجاهل أجزاء اللاعبين والأدوات
        local root = part.AssemblyRootPart
        if root and root.Parent and root.Parent:FindFirstChildOfClass("Humanoid") then return false end
        if part:FindFirstAncestorWhichIsA("Accessory") or part:FindFirstAncestorWhichIsA("Tool") then return false end

        -- 🔴 1. حماية من السرعات الوهمية (NaN) التي تستخدم لعمل كراش أو تطيير
        if part.Velocity.X ~= part.Velocity.X or part.RotVelocity.X ~= part.RotVelocity.X then 
            return true 
        end

        -- 🔴 2. حد الخطر للسرعة والدوران (دوران > 50، سرعة > 100)
        if part.Velocity.Magnitude > 100 or part.RotVelocity.Magnitude > 50 then
            return true
        end

        return false
    end

    -- ==========================================
    -- دالة النفي: تدمير حركي ورمي في الفراغ
    -- ==========================================
    local function BanishPart(part)
        pcall(function()
            part.Velocity = Vector3.new(0, 0, 0)
            part.RotVelocity = Vector3.new(0, 0, 0)
            part.CanCollide = false
            part.Massless = true -- جعلها بلا وزن حتى لو اصطدمت بالخطأ
            -- رميها للفراغ السفلي لكي يقوم محرك روبلوكس بمسحها تلقائياً
            part.CFrame = CFrame.new(0, -99999, 0) 
        end)
    end

    -- ==========================================
    -- زر التفعيل
    -- ==========================================
    Tab:AddToggle("حماية من التطيير (متقدم) / Anti-Fling", function(state)
        protectionActive = state
        
        if state then
            Notify("🛡️ حماية متقدمة / Adv. Protection ON", "تم تفعيل الرادار اللحظي.\nReal-time radar activated.")
            trackedParts = {}

            -- 1. فحص مبدئي لجميع القطع الموجودة حالياً
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v.Anchored then
                    trackedParts[v] = true
                end
            end

            -- 2. تتبع لحظي (بدون لاق) لأي قطعة جديدة تظهر في الماب
            addedConnection = Workspace.DescendantAdded:Connect(function(v)
                if v:IsA("BasePart") then
                    -- استخدام defer لضمان تحميل القطعة بالكامل قبل الفحص
                    task.defer(function()
                        if v and v.Parent and not v.Anchored then
                            trackedParts[v] = true
                        end
                    end)
                end
            end)

            -- إزالة القطع المحذوفة من الجدول لتوفير الرام
            removingConnection = Workspace.DescendantRemoving:Connect(function(v)
                if trackedParts[v] then
                    trackedParts[v] = nil
                end
            end)

            -- 3. لوب الفيزياء السريع (يشتغل قبل اصطدام الأشياء)
            protectionLoop = RunService.Stepped:Connect(function()
                for part, _ in pairs(trackedParts) do
                    if isDangerousPart(part) then
                        BanishPart(part)
                    end
                end
            end)

        else
            Notify("🛑 حماية متوقفة / Protection OFF", "تم إيقاف نظام الحماية.\nProtection disabled.")
            
            -- تنظيف وتوقيف اللوبات
            if protectionLoop then protectionLoop:Disconnect() protectionLoop = nil end
            if addedConnection then addedConnection:Disconnect() addedConnection = nil end
            if removingConnection then removingConnection:Disconnect() removingConnection = nil end
            trackedParts = {}
        end
    end)
    
    Tab:AddLine()
end
