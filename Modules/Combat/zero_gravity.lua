-- [[ Cryptic Hub - العوم في الفضاء (3D) ]]
-- المطور: Cryptic | التحديث: إضافة دفعة انطلاق للأمام عند التفعيل

return function(Tab, UI)
    local Player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local cam = workspace.CurrentCamera

    local isZeroGravity = false
    local connection
    local force, attachment, gyro

    Tab:AddToggle("جادبيه صفر / zero gravity", function(state)
        isZeroGravity = state

        local Character = Player.Character
        local root = Character and Character:FindFirstChild("HumanoidRootPart")
        local hum = Character and Character:FindFirstChildOfClass("Humanoid")

        if not root or not hum then return end

        if isZeroGravity then
            hum.PlatformStand = true

            -- تنظيف القديم لتجنب التكرار
            if root:FindFirstChild("ZeroGravAttachment") then root.ZeroGravAttachment:Destroy() end
            if root:FindFirstChild("ZeroGravGyro") then root.ZeroGravGyro:Destroy() end

            attachment = Instance.new("Attachment", root)
            attachment.Name = "ZeroGravAttachment"

            -- 1. قوة انعدام الجاذبية
            force = Instance.new("VectorForce", root)
            force.Attachment0 = attachment
            force.RelativeTo = Enum.ActuatorRelativeTo.World
            force.ApplyAtCenterOfMass = true

            local totalMass = 0
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then totalMass = totalMass + part.Mass end
            end
            force.Force = Vector3.new(0, totalMass * workspace.Gravity, 0)

            -- 2. مثبت الدوران (عشان شخصيتك تلف مع الكاميرا)
            gyro = Instance.new("BodyGyro", root)
            gyro.Name = "ZeroGravGyro"
            gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            gyro.P = 3000 -- نعومة الالتفاف

            -- [[ التعديل هنا: إعطاء دفعة انطلاق فورية باتجاه الكاميرا ]]
            -- الرقم 50 يمثل قوة الدفعة (تقدر تزيده لو تبيها أقوى)
            root.AssemblyLinearVelocity = cam.CFrame.LookVector * 50

            UI:Notify("🚀 عوم الفضاء مفعل: انطلاق!")

            local floatSpeed = 40 -- السرعة القصوى للسباحة

            connection = RunService.RenderStepped:Connect(function()
                if not isZeroGravity or not root then return end

                local moveDir = hum.MoveDirection
                
                -- جعل الشخصية تنظر دائماً باتجاه الكاميرا
                gyro.CFrame = cam.CFrame

                if moveDir.Magnitude > 0 then
                    -- استخراج اتجاه الكاميرا الفعلي (للأعلى، للأسفل، لليمين، لليسار)
                    local look = cam.CFrame.LookVector
                    local right = cam.CFrame.RightVector
                    
                    -- تسطيح المتجهات لقراءة حركة الجويستيك بدقة
                    local flatLook = Vector3.new(look.X, 0, look.Z)
                    if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
                    
                    local flatRight = Vector3.new(right.X, 0, right.Z)
                    if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end
                    
                    -- تحويل حركة الجويستيك الثنائية لاتجاه ثلاثي الأبعاد
                    local zInput = moveDir:Dot(flatLook)
                    local xInput = moveDir:Dot(flatRight)
                    
                    local floatDir = (look * zInput) + (right * xInput)
                    
                    if floatDir.Magnitude > 0 then
                        -- التسارع الفيزيائي السلس (السباحة)
                        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(floatDir.Unit * floatSpeed, 0.04)
                    end
                else
                    -- الانزلاق الفضائي البطيء عند ترك الجويستيك
                    root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(Vector3.zero, 0.01)
                end
            end)

        else
            -- إيقاف السكربت وإرجاع الطبيعة
            if connection then connection:Disconnect() end
            if force then force:Destroy() end
            if attachment then attachment:Destroy() end
            if gyro then gyro:Destroy() end
            
            if hum then 
                hum.PlatformStand = false 
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            UI:Notify("🌍 تمت استعادة الجاذبية")
        end
    end)
end
