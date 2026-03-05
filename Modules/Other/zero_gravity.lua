-- [[ Cryptic Hub - العوم في الفضاء (Zero Gravity 3D Stable) V4 ]]
-- المطور: يامي (Yami) | الوصف: طيران 3D ناعم جداً، بدون قلتشات اللمس، مع محدد سرعة لمنع الطيران العشوائي

return function(Tab, UI)
    local Player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local cam = workspace.CurrentCamera

    local isZeroGravity = false
    local connection
    local force, attachment
    
    local MAX_SPEED = 40 -- أقصى سرعة ممكن توصل لها في الفضاء لمنع الطيران العشوائي

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

            -- حساب الوزن بدقة لإلغاء الجاذبية 100%
            local totalMass = 0
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    totalMass = totalMass + part.Mass
                end
            end
            
            force.Force = Vector3.new(0, totalMass * workspace.Gravity, 0)

            -- دفعة خفيفة للبدء
            root.AssemblyLinearVelocity = cam.CFrame.LookVector * 5

            SendRobloxNotification("Cryptic Hub", "🚀 صفر جاذبية مفعل! (ثبات تام + تحكم 3D)")

            connection = RunService.RenderStepped:Connect(function()
                if not isZeroGravity or not root then return end

                local moveDir = hum.MoveDirection
                
                if moveDir.Magnitude > 0 then
                    -- استخراج نية اللاعب من الكاميرا
                    local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
                    if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
                    
                    local flatRight = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
                    if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end
                    
                    local forwardIntent = moveDir:Dot(flatLook)
                    local rightIntent = moveDir:Dot(flatRight)
                    
                    -- تطبيق الحركة 3D الحقيقية (لفوق وتحت)
                    local trueLook = cam.CFrame.LookVector
                    local trueRight = cam.CFrame.RightVector
                    
                    local floatDir = (trueLook * forwardIntent) + (trueRight * rightIntent)
                    
                    if floatDir.Magnitude > 0 then
                        -- إضافة قوة الدفع
                        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + (floatDir.Unit * 1.5)
                    end
                end

                -- [[ محدد السرعة (Speed Limiter) لحمايتك من الطيران العشوائي والموت ]]
                if root.AssemblyLinearVelocity.Magnitude > MAX_SPEED then
                    root.AssemblyLinearVelocity = root.AssemblyLinearVelocity.Unit * MAX_SPEED
                end

                -- فرملة الفضاء (مقاومة هواء خفيفة لكي تتوقف بسلاسة عند ترك الجويستيك)
                root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(Vector3.zero, 0.02)
            end)

        else
            -- التنظيف وإعادة اللاعب للأرض
            if connection then connection:Disconnect() end
            if force then force:Destroy() end
            if attachment then attachment:Destroy() end
            
            if hum then 
                hum.PlatformStand = false 
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            SendRobloxNotification("Cryptic Hub", "🌍 عادت الجاذبية لك")
        end
    end)
end
