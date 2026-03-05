-- [[ Cryptic Hub - العوم في الفضاء (Zero Gravity 3D + Bounce) ]]
-- المطور: يامي (Yami) | الوصف: عوم حقيقي، تحكم 3D بالكاميرا، ارتداد من الجدران واللاعبين

return function(Tab, UI)
    local Player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local cam = workspace.CurrentCamera

    local isZeroGravity = false
    local connection
    local force, attachment
    local touchConnections = {} 

    local function SendRobloxNotification(title, text)
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = title, Text = text, Duration = 4 }) end)
    end

    Tab:AddToggle("صفر جاذبيه / zero gravity", function(state)
        isZeroGravity = state

        local Character = Player.Character
        local root = Character and Character:FindFirstChild("HumanoidRootPart")
        local hum = Character and Character:FindFirstChildOfClass("Humanoid")

        if not root or not hum then return end

        if isZeroGravity then
            hum.PlatformStand = true

            if root:FindFirstChild("ZeroGravAttachment") then
                root.ZeroGravAttachment:Destroy()
            end

            attachment = Instance.new("Attachment", root)
            attachment.Name = "ZeroGravAttachment"

            force = Instance.new("VectorForce", root)
            force.Attachment0 = attachment
            force.RelativeTo = Enum.ActuatorRelativeTo.World
            force.ApplyAtCenterOfMass = true

            -- حساب الوزن بدقة لإلغاء الجاذبية (نفس الكود الأول المستقر بدون تغيير خصائص الجسم)
            local totalMass = 0
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    totalMass = totalMass + part.Mass
                    
                    -- [[ إضافة نظام الارتداد عند اللمس (جدران أو لاعبين) ]]
                    table.insert(touchConnections, part.Touched:Connect(function(hit)
                        if not isZeroGravity then return end
                        -- تجاهل أجزاء شخصيتك نفسها
                        if hit:IsDescendantOf(Character) then return end
                        -- تجاهل الأشياء الوهمية (اللي ما لها تصادم)
                        if not hit.CanCollide then return end
                        
                        -- حساب اتجاه الارتداد (عكس اتجاه الضربة)
                        local bounceDir = (part.Position - hit.Position).Unit
                        -- إعطاء دفعة ارتدادية
                        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + (bounceDir * 15)
                    end))
                end
            end
            
            force.Force = Vector3.new(0, totalMass * workspace.Gravity, 0)

            -- دفعة البداية الخفيفة للأمام
            root.AssemblyLinearVelocity = cam.CFrame.LookVector * 5

            SendRobloxNotification("Cryptic Hub", "🚀 صفر جاذبية مفعل! (وجه الكاميرا للسماء للطيران)")

            connection = RunService.RenderStepped:Connect(function()
                if not isZeroGravity or not root then return end

                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    -- [[ نظام الطيران 3D: استخراج نية اللاعب من الجويستيك ]]
                    local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
                    if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
                    
                    local flatRight = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
                    if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end
                    
                    local forwardIntent = moveDir:Dot(flatLook)
                    local rightIntent = moveDir:Dot(flatRight)
                    
                    -- [[ تطبيق النية على الاتجاهات الحقيقية 3D للكاميرا ]]
                    local trueLook = cam.CFrame.LookVector
                    local trueRight = cam.CFrame.RightVector
                    
                    local floatDir = (trueLook * forwardIntent) + (trueRight * rightIntent)
                    
                    if floatDir.Magnitude > 0 then
                        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + (floatDir.Unit * 1.5)
                    end
                end

                -- فرملة الفضاء (مقاومة هواء خفيفة جداً)
                root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(Vector3.zero, 0.015)
            end)

        else
            -- التنظيف
            if connection then connection:Disconnect() end
            if force then force:Destroy() end
            if attachment then attachment:Destroy() end
            
            for _, con in pairs(touchConnections) do
                con:Disconnect()
            end
            touchConnections = {}
            
            if hum then 
                hum.PlatformStand = false 
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            SendRobloxNotification("Cryptic Hub", "🌍 عادت الجاذبية لك")
        end
    end)
end
