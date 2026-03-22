-- [[ Cryptic Hub - حماية من التطيير (Anti-Fling Protection) ]]
-- الوصف: اكتشاف القطع السريعة التي تستخدم للتطيير ونفيها بعيداً لحماية اللاعبين

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer

    local protectionActive = false
    local protectionLoop = nil
    local cacheLoop = nil
    local unanchoredParts = {}

    -- دالة الإشعارات
    local function Notify(arText, enText)
        pcall(function() StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = arText .. "\n" .. enText, Duration = 3}) end)
    end

    -- ==========================================
    -- فلتر الأمان: التأكد أن القطعة ليست جزءاً من لاعب أو أداة طبيعية
    -- ==========================================
    local function isDangerousPart(part)
        -- تجاهل القطع المثبتة أو غير المرئية
        if not part:IsA("BasePart") or part.Anchored or part.Transparency == 1 then return false end
        
        -- تجاهل القطع المرتبطة بشخصيات اللاعبين
        local root = part.AssemblyRootPart
        if root and root.Parent and root.Parent:FindFirstChildOfClass("Humanoid") then return false end
        
        -- تجاهل الإكسسوارات والأدوات
        if part:FindFirstAncestorWhichIsA("Accessory") or part:FindFirstAncestorWhichIsA("Tool") then return false end

        -- 🔴 شرط الخطر: إذا كانت سرعة القطعة غير طبيعية (تتحرك بسرعة جنونية)
        -- السرعة العادية للسقوط نادراً ما تتجاوز 100، لذلك 150 رقم ممتاز لفلترة التطيير
        if part.Velocity.Magnitude > 150 or part.RotVelocity.Magnitude > 100 then
            return true
        end

        return false
    end

    -- ==========================================
    -- دالة النفي: تصفير السرعة ورمي القطعة بعيداً
    -- ==========================================
    local function BanishPart(part)
        pcall(function()
            -- تصفير السرعة
            part.Velocity = Vector3.new(0, 0, 0)
            part.RotVelocity = Vector3.new(0, 0, 0)
            part.CanCollide = false
            
            -- رميها في مكان بعيد جداً (الفراغ)
            part.CFrame = CFrame.new(99999, 99999, 99999)
        end)
    end

    -- ==========================================
    -- زر التفعيل
    -- ==========================================
    Tab:AddToggle("حماية من التطيير / Anti-Fling", function(state)
        protectionActive = state
        
        if state then
            Notify("🛡️ حماية مفعلة / Protection ON", "تم تشغيل رادار حماية اللاعبين.\nAnti-Fling radar activated.")

            -- 1. لوب لتحديث قائمة القطع غير المثبتة كل ثانيتين (لمنع اللاق)
            if not cacheLoop then
                cacheLoop = task.spawn(function()
                    while protectionActive do
                        local tempTable = {}
                        for _, v in ipairs(Workspace:GetDescendants()) do
                            if v:IsA("BasePart") and not v.Anchored then
                                table.insert(tempTable, v)
                            end
                        end
                        unanchoredParts = tempTable
                        task.wait(2) -- تحديث كل ثانيتين لتقليل الضغط على اللعبة
                    end
                end)
            end

            -- 2. لوب سريع جداً للتحقق من سرعة القطع المحفوظة
            if not protectionLoop then
                protectionLoop = RunService.Heartbeat:Connect(function()
                    for _, part in ipairs(unanchoredParts) do
                        if part and part.Parent then
                            if isDangerousPart(part) then
                                BanishPart(part)
                            end
                        end
                    end
                end)
            end

        else
            Notify("🛑 حماية متوقفة / Protection OFF", "تم إيقاف نظام الحماية.\nProtection disabled.")
            
            -- إيقاف اللوبات عند إطفاء الزر
            protectionActive = false
            if protectionLoop then 
                protectionLoop:Disconnect() 
                protectionLoop = nil 
            end
            if cacheLoop then
                task.cancel(cacheLoop)
                cacheLoop = nil
            end
            unanchoredParts = {}
        end
    end)
    
    Tab:AddLine()
end
