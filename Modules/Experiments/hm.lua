-- [[ Cryptic Hub - التحكم التخاطري بالبلوكات (Telekinesis Aura FE) ]]
-- المطور: أروى (Arwa) | الوصف: رفع أي بلوكة (حتى العملاقة) بأمان تام بدون ما تطيرك!

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

    -- دالة التنظيف (لإسقاط البلوكات واسترجاع وزنها وتصادمها)
    local function releaseAllParts()
        for part, data in pairs(capturedParts) do
            if part and part.Parent then
                if data.bp then data.bp:Destroy() end
                if data.bg then data.bg:Destroy() end
                if data.nccFolder then data.nccFolder:Destroy() end
                -- استرجاع الوزن الطبيعي
                pcall(function() part.Massless = false end)
            end
        end
        capturedParts = {}
    end

    -- دالة فحص البلوكات
    local function isValidPart(part)
        if not part or not part:IsA("BasePart") then return false end
        if part.Anchored then return false end 
        
        -- تجاهل أجزاء اللاعبين
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChildOfClass("Humanoid") then return false end
        
        return true
    end

    Tab:AddToggle("هالة الرفع التخاطري / Telekinesis", function(state)
        isActive = state
        
        if isActive then
            SendRobloxNotification("Cryptic Hub", "🌌 الهالة مفعلة! (تمنع تصادم البلوكات بك وترفع الأحجام العملاقة)")
            
            connection = RunService.Heartbeat:Connect(function()
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- 1. البحث عن بلوكات جديدة قريبة لالتقاطها
                for _, obj in pairs(workspace:GetDescendants()) do
                    if isValidPart(obj) then
                        local distance = (obj.Position - root.Position).Magnitude
                        if distance <= SCAN_RADIUS then
                            if not capturedParts[obj] then
                                
                                -- 🔴 1. إلغاء الوزن بالكامل لرفع الأشياء العملاقة بسهولة
                                obj.Massless = true
                                
                                -- 🔴 2. منع التصادم بين البلوكة وشخصيتك (NoCollisionConstraint)
                                local nccFolder = Instance.new("Folder")
                                nccFolder.Name = "Cryptic_NCC"
                                nccFolder.Parent = obj
                                
                                for _, charPart in pairs(char:GetChildren()) do
                                    if charPart:IsA("BasePart") then
                                        local ncc = Instance.new("NoCollisionConstraint")
                                        ncc.Part0 = charPart
                                        ncc.Part1 = obj
                                        ncc.Parent = nccFolder
                                    end
                                end

                                -- محرك الرفع (مضاعفة القوة 20 مرة!)
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

                                capturedParts[obj] = {bp = bp, bg = bg, nccFolder = nccFolder, offset = randomOffset}
                            end
                        end
                    end
                end

                -- 2. تحديث مواقع البلوكات
                for part, data in pairs(capturedParts) do
                    if part and part.Parent and not part.Anchored then
                        local dist = (part.Position - root.Position).Magnitude
                        
                        -- إسقاط البلوكة إذا ابتعدت
                        if dist > SCAN_RADIUS * 2 then
                            if data.bp then data.bp:Destroy() end
                            if data.bg then data.bg:Destroy() end
                            if data.nccFolder then data.nccFolder:Destroy() end
                            pcall(function() part.Massless = false end)
                            capturedParts[part] = nil
                        else
                            data.bp.Position = root.Position + Vector3.new(0, LEVITATION_HEIGHT, 0) + data.offset
                            data.bg.CFrame = root.CFrame * CFrame.Angles(math.rad(math.random(-15, 15)), tick() % 360, math.rad(math.random(-15, 15)))
                        end
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
    Tab:AddParagraph("ملاحظة: البلوكات العملاقة ترتفع الآن، ولن تتصادم معك بفضل نظام NoCollision الذكي (لكنها ستصدم الآخرين!).")
end
