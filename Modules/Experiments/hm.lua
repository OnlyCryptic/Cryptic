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
    local capturedOrder = {} 
    
    local START_HEIGHT = 15
    local SCAN_RADIUS = 60

    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 4
            })
        end)
    end

    local function releaseAllParts()
        for part, data in pairs(capturedParts) do
            if part and part.Parent then
                if data.bp then data.bp:Destroy() end
                if data.bg then data.bg:Destroy() end
                pcall(function() 
                    part.Massless = false 
                    part.CanCollide = data.origCollide
                    part.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    part.AssemblyAngularVelocity = Vector3.new(0,0,0)
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
                            bp.P = 200000
                            bp.D = 1500 
                            bp.Parent = obj

                            local bg = Instance.new("BodyGyro")
                            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                            bg.P = 50000
                            bg.Parent = obj

                            -- إعطاء السرعة مرة واحدة فقط للبلوك الجديد
                            pcall(function()
                                obj.AssemblyLinearVelocity = Vector3.new(0, 25, 0)
                                obj.AssemblyAngularVelocity = Vector3.new(0,0,0)
                            end)

                            capturedParts[obj] = {
                                bp = bp, 
                                bg = bg, 
                                origCollide = origCollide
                            }

                            table.insert(capturedOrder, obj)
                        end
                    end
                end

                -- تحريك البلوكات بنظام البرج
                local currentStackHeight = START_HEIGHT
                for i, part in ipairs(capturedOrder) do
                    local data = capturedParts[part]
                    if part and part.Parent and data and not part.Anchored then
                        
                        local targetPos = root.Position + Vector3.new(0, currentStackHeight, 0)
                        data.bp.Position = targetPos
                        data.bg.CFrame = root.CFrame
                        
                        pcall(function()
                            part.CanCollide = false
                        end)

                        currentStackHeight = currentStackHeight + (part.Size.Y + 0.5)
                    else
                        capturedParts[part] = nil
                        table.remove(capturedOrder, i)
                    end
                end
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
            releaseAllParts()
            SendRobloxNotification("Cryptic Hub", "⬇️ تم إسقاط البرج.")
        end
    end)
    
    Tab:AddLine()
end