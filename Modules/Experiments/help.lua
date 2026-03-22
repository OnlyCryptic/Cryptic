-- [[ Cryptic Hub - حماية شاملة للجميع (Global Anti-Fling V4.0) ]]
-- الوصف: مظلة أمان حول كل اللاعبين، تدفن أي بلوكة متحركة تقترب منهم

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")

    local protectionActive = false
    local protectionLoop = nil

    -- دالة الإشعارات
    local function Notify(arText, enText)
        pcall(function() StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = arText .. "\n" .. enText, Duration = 3}) end)
    end

    -- ==========================================
    -- الفلتر: هل البلوكة تشكل خطراً؟
    -- ==========================================
    local function isDangerousPart(part)
        if not part or not part.Parent or not part:IsA("BasePart") then return false end
        if part.Anchored or part.Transparency == 1 then return false end
        
        -- استثناء شخصيات اللاعبين والأدوات
        local root = part.AssemblyRootPart
        if root and root.Parent and root.Parent:FindFirstChildOfClass("Humanoid") then return false end
        if part:FindFirstAncestorWhichIsA("Accessory") or part:FindFirstAncestorWhichIsA("Tool") then return false end

        -- شرط الحركة: تتحرك ولو قليلاً
        if part.Velocity.Magnitude > 1 or part.RotVelocity.Magnitude > 1 then
            return true
        end

        return false
    end

    -- ==========================================
    -- دالة النفي الجذري تحت الأرض
    -- ==========================================
    local function BanishPart(part)
        pcall(function()
            -- تدمير محركات الهاك
            for _, v in ipairs(part:GetChildren()) do
                if v:IsA("BodyMover") or v:IsA("AlignPosition") or v:IsA("Torque") or v:IsA("RocketPropulsion") then
                    v:Destroy()
                end
            end

            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.Velocity = Vector3.new(0, 0, 0)
            part.RotVelocity = Vector3.new(0, 0, 0)
            
            -- النفي والتثبيت
            part.CFrame = CFrame.new(0, -5000, 0)
            part.Anchored = true 
        end)
    end

    -- ==========================================
    -- زر التفعيل
    -- ==========================================
    Tab:AddToggle("درع السيرفر (حماية للكل) / Global Anti-Fling", function(state)
        protectionActive = state
        
        if state then
            Notify("🛡️ درع السيرفر مفعل / Global Shield ON", "تم تشغيل مظلة الأمان لكل اللاعبين.\nProtecting all players.")

            protectionLoop = RunService.Heartbeat:Connect(function()
                -- 1. جمع قائمة بكل البلوكات الخطيرة في الماب
                local dangerousParts = {}
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") and not part.Anchored then
                        if isDangerousPart(part) then
                            table.insert(dangerousParts, part)
                        end
                    end
                end

                -- 2. التحقق من مسافة هذه البلوكات عن *أي لاعب* في السيرفر
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local playerPos = player.Character.HumanoidRootPart.Position
                        
                        for _, part in ipairs(dangerousParts) do
                            if part and part.Parent and not part.Anchored then
                                local distance = (part.Position - playerPos).Magnitude
                                -- إذا اقتربت البلوكة مسافة 30 خطوة من أي لاعب، يتم نفيها
                                if distance < 30 then
                                    BanishPart(part)
                                end
                            end
                        end
                    end
                end
            end)

        else
            Notify("🛑 إيقاف الدرع / Global Shield OFF", "تم إيقاف حماية السيرفر.\nServer protection disabled.")
            
            if protectionLoop then 
                protectionLoop:Disconnect() 
                protectionLoop = nil 
            end
        end
    end)
    
    Tab:AddLine()
end
