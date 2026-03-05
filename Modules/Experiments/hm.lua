-- [[ Cryptic Hub - التحكم التخاطري بالبلوكات (Telekinesis Aura FE) V10 ]]
-- المطور: أروى (Arwa) | الوصف: التقاط من مسافات شاسعة، طيران من فوق المباني، صلبة للجميع وتخترقك أنت فقط!

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local isActive = false
    local connection = nil
    local capturedParts = {} 
    
    local LEVITATION_HEIGHT = 45 -- طيران عالي جداً لتجاوز المباني وعدم الاصطدام بها
    local SCAN_RADIUS = 1500 -- مسافة التقاط تغطي الماب تقريباً!

    local function SendRobloxNotification(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 5 }) end)
    end

    local function releaseAllParts()
        for part, data in pairs(capturedParts) do
            if part and part.Parent then
                if data.bp then data.bp:Destroy() end
                if data.bg then data.bg:Destroy() end
                if data.nccFolder then data.nccFolder:Destroy() end
                pcall(function() part.Massless = false end)
            end
        end
        capturedParts = {}
    end

    local function isValidPart(part)
        if not part or not part:IsA("BasePart") then return false end
        if part.Anchored then return false end 
        
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChildOfClass("Humanoid") then return false end
        
        return true
    end

    Tab:AddToggle("هالة الرفع التخاطري / Telekinesis", function(state)
        isActive = state
        
        if isActive then
            SendRobloxNotification("Cryptic Hub", "🌌 الهالة مفعلة! سيتم التقاط البلوكات من مسافات شاسعة ورفعها فوق المباني.")
            
            connection = RunService.Heartbeat:Connect(function()
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- 1. رادار التقاط البلوكات العملاق
                for _, obj in pairs(workspace:GetDescendants()) do
                    if isValidPart(obj) then
                        local distance = (obj.Position - root.Position).Magnitude
                        if distance <= SCAN_RADIUS then
                            if not capturedParts[obj] then
                                
                                -- الحفاظ على صلابتها لتدمير الماب وعدم السقوط
                                obj.CanCollide = true 
                                obj.Massless = true
                                
                                -- 🛡️ درع منع التصادم المطور (بينك وبين البلوكة فقط)
                                local nccFolder = obj:FindFirstChild("Cryptic_NCC")
                                if not nccFolder then
                                    nccFolder = Instance.new("Folder")
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
                                end

                                -- محرك الرفع الجبار
                                local bp = Instance.new("BodyPosition")
                                bp.Name = "Cryptic_Telekinesis_BP"
                                bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bp.P = 150000 -- قوة مرعبة لسحبها حتى لو علقت
                                bp.D = 1500 
                                bp.Parent = obj

                                local bg = Instance.new("BodyGyro")
                                bg.Name = "Cryptic_Telekinesis_BG"
                                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                                bg.Parent = obj

                                local randomOffset = Vector3.new(
                                    math.random(-25, 25), 
                                    math.random(-5, 10),   
                                    math.random(-25, 25)  
                                )

                                capturedParts[obj] = {bp = bp, bg = bg, nccFolder = nccFolder, offset = randomOffset}
                            end
                        end
                    end
                end

                -- 2. تحديث مواقع البلوكات للملاحقة الأبدية
                for part, data in pairs(capturedParts) do
                    if part and part.Parent and not part.Anchored then
                        -- ستطير عالياً في السماء (45 متر) لتتجاوز المباني وتلحقك أينما كنت
                        data.bp.Position = root.Position + Vector3.new(0, LEVITATION_HEIGHT, 0) + data.offset
                        data.bg.CFrame = root.CFrame * CFrame.Angles(math.rad(math.random(-15, 15)), tick() % 360, math.rad(math.random(-15, 15)))
                    else
                        capturedParts[part] = nil
                    end
                end
            end)
        else
            if connection then connection:Disconnect(); connection = nil end
            releaseAllParts()
            SendRobloxNotification("Cryptic Hub", "⬇️ تم إيقاف الهالة، البلوكات تسقط الآن كالمطر.")
        end
    end)
    
    Tab:AddLine()
    Tab:AddParagraph("ملاحظة: الرادار الآن يمسح الماب بالكامل (1500 متر)! البلوكات ستطير عالياً لتجنب الجدران ولن تسقط في الفراغ أبدًا.")
end
