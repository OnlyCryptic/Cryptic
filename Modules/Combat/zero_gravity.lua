-- [[ Cryptic Hub - العوم في الفضاء المطور ]]
-- المطور: Cryptic | الإصلاح: حساب دقيق للجاذبية + حركة 3D مطابقة للكاميرا

return function(Tab, UI)
    local Player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local cam = workspace.CurrentCamera

    local isZeroGravity = false
    local connection
    local force, attachment

    Tab:AddToggle("العوم في الفضاء 🚀", function(state)
        isZeroGravity = state

        local Character = Player.Character
        local root = Character and Character:FindFirstChild("HumanoidRootPart")
        local hum = Character and Character:FindFirstChildOfClass("Humanoid")

        if not root or not hum then return end

        if isZeroGravity then
            -- استخدام PlatformStand أفضل بكثير للجوال من تغيير الـ State
            hum.PlatformStand = true

            -- تنظيف أي مرفقات قديمة لتجنب القلتشات
            if root:FindFirstChild("ZeroGravAttachment") then
                root.ZeroGravAttachment:Destroy()
            end

            attachment = Instance.new("Attachment", root)
            attachment.Name = "ZeroGravAttachment"

            force = Instance.new("VectorForce", root)
            force.Attachment0 = attachment
            force.RelativeTo = Enum.ActuatorRelativeTo.World
            force.ApplyAtCenterOfMass = true

            -- الحساب الدقيق لكتلة الشخصية بالكامل لضمان إلغاء الجاذبية 100%
            local totalMass = 0
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    totalMass = totalMass + part.Mass
                end
            end
            
            -- تطبيق القوة المعاكسة للجاذبية
            force.Force = Vector3.new(0, totalMass * workspace.Gravity, 0)

            UI:Notify("🚀 أنت الآن تعوم في الفضاء بوزن منعدم!")

            connection = RunService.RenderStepped:Connect(function()
                if not isZeroGravity or not root then return end

                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    -- استخراج اتجاه الكاميرا للحركة ثلاثية الأبعاد (3D)
                    local look = cam.CFrame.LookVector
                    local right = cam.CFrame.RightVector
                    
                    local flatLook = Vector3.new(look.X, 0, look.Z).Unit
                    local flatRight = Vector3.new(right.X, 0, right.Z).Unit
                    
                    -- تحويل حركة الجويستيك لتتطابق مع اتجاه نظر الكاميرا
                    local zInput = moveDir:Dot(flatLook)
                    local xInput = moveDir:Dot(flatRight)
                    
                    local floatDir = (look * zInput) + (right * xInput)
                    
                    if floatDir.Magnitude > 0 then
                        -- الدفع ببطء ليعطي إحساس السباحة في الفضاء
                        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + (floatDir.Unit * 1.2)
                    end
                end

                -- تطبيق "مقاومة هواء" خفيفة جداً لكي لا تتسارع الشخصية للمالانهاية
                root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(Vector3.zero, 0.015)
            end)

        else
            -- إرجاع كل شيء لطبيعته
            if connection then connection:Disconnect() end
            if force then force:Destroy() end
            if attachment then attachment:Destroy() end
            
            if hum then 
                hum.PlatformStand = false 
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            UI:Notify("🌍 عادت الجاذبية لك")
        end
    end)
end
