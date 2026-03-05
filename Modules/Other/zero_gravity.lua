-- [[ Cryptic Hub - العوم في الفضاء المطور V3 ]]
-- المطور: Cryptic | التحديث: طيران 3D بالجويستيك + ارتداد من الجدران + ارتداد عند ضرب اللاعبين

return function(Tab, UI)
    local Player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local cam = workspace.CurrentCamera

    local isZeroGravity = false
    local connection
    local force, attachment
    local touchConnections = {} -- لحفظ أحداث اللمس وإغلاقها لاحقاً

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

            local totalMass = 0
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    totalMass = totalMass + part.Mass
                    
                    -- [[ 1. جعل اللاعب "مطاطي" ليرتد من الجدران بشكل واقعي ]]
                    part.CustomPhysicalProperties = PhysicalProperties.new(
                        0.7, -- الكثافة
                        0.0, -- الاحتكاك (صفر عشان تتزحلق في الهواء)
                        1.0, -- الارتداد (1 يعني ارتداد كامل مثل الكرة)
                        1.0, -- أولوية الاحتكاك
                        100  -- أولوية الارتداد (يغلب ارتداد الجدران العادية)
                    )

                    -- [[ 2. نظام الارتداد عند الاصطدام بلاعبين آخرين ]]
                    table.insert(touchConnections, part.Touched:Connect(function(hit)
                        if not isZeroGravity then return end
                        local otherChar = hit:FindFirstAncestorOfClass("Model")
                        
                        -- إذا كان اللي صدمك هو لاعب آخر (عنده Humanoid وما هو شخصيتك)
                        if otherChar and otherChar ~= Character and otherChar:FindFirstChild("Humanoid") then
                            -- حساب الاتجاه المعاكس للاصطدام
                            local pushDir = (root.Position - hit.Position).Unit
                            -- إضافة قوة دفع لتبتعد عنه
                            root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + (pushDir * 20)
                        end
                    end))
                end
            end
            
            force.Force = Vector3.new(0, totalMass * workspace.Gravity, 0)
            root.AssemblyLinearVelocity = cam.CFrame.LookVector * 10

            -- UI:Notify("🚀 أنت الآن تعوم في الفضاء (وجه الكاميرا للتوجيه)!") -- استخدمها لو الدالة موجودة عندك بمكتبتك

            connection = RunService.RenderStepped:Connect(function()
                if not isZeroGravity or not root then return end

                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    -- [[ 3. نظام الحركة 3D المتطور للجويستيك ]]
                    local look = cam.CFrame.LookVector
                    local right = cam.CFrame.RightVector
                    
                    -- تحويل اتجاه الكاميرا لمسطح لمعرفة أين يشير الجويستيك
                    local flatLook = Vector3.new(look.X, 0, look.Z)
                    if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
                    
                    local flatRight = Vector3.new(right.X, 0, right.Z)
                    if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end
                    
                    -- حساب نسبة الحركة للأمام/للخلف واليمين/اليسار من الجويستيك
                    local zInput = moveDir:Dot(flatLook)
                    local xInput = moveDir:Dot(flatRight)
                    
                    -- دمج المدخلات مع اتجاه الكاميرا الثلاثي الأبعاد الحقيقي! (للطيران فوق وتحت)
                    local floatDir = (look * zInput) + (right * xInput)
                    
                    if floatDir.Magnitude > 0 then
                        -- دفع الشخصية في الاتجاه المطلوب
                        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + (floatDir.Unit * 1.5)
                    end
                end

                -- مقاومة هواء خفيفة جداً لكي تهدأ حركتك بمرور الوقت
                root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(Vector3.zero, 0.01)
            end)

        else
            -- [[ تنظيف كل شيء عند الإيقاف ]]
            if connection then connection:Disconnect() end
            if force then force:Destroy() end
            if attachment then attachment:Destroy() end
            
            for _, con in pairs(touchConnections) do
                con:Disconnect()
            end
            touchConnections = {}

            -- إرجاع خصائص الجسم لطبيعتها
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CustomPhysicalProperties = nil
                    end
                end
            end
            
            if hum then 
                hum.PlatformStand = false 
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            -- UI:Notify("🌍 عادت الجاذبية لك")
        end
    end)
end
