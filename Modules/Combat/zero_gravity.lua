return function(Tab, UI)

    local Player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")

    local isZeroGravity = false
    local connection
    local force

    Tab:AddToggle("العوم في الفضاء 🚀", function(state)

        isZeroGravity = state

        local Character = Player.Character
        local root = Character and Character:FindFirstChild("HumanoidRootPart")
        local hum = Character and Character:FindFirstChild("Humanoid")

        if not root or not hum then return end

        if isZeroGravity then
            
            hum:ChangeState(Enum.HumanoidStateType.Physics)

            -- إنشاء Attachment
            local attachment = Instance.new("Attachment", root)

            -- إنشاء VectorForce
            force = Instance.new("VectorForce")
            force.Attachment0 = attachment
            force.RelativeTo = Enum.ActuatorRelativeTo.World
            force.ApplyAtCenterOfMass = true
            force.Parent = root

            UI:Notify("🚀 أنت الآن تعوم في الفضاء")

            connection = RunService.RenderStepped:Connect(function()

                -- إلغاء تأثير الجاذبية فقط عنك
                force.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity, 0)

                -- حركة حرة بالجويستيك (3D)
                local moveDir = hum.MoveDirection

                if moveDir.Magnitude > 0 then
                    root.AssemblyLinearVelocity += moveDir * 2
                end

                -- منع السرعة الزائدة
                root.AssemblyLinearVelocity =
                    root.AssemblyLinearVelocity:Lerp(Vector3.zero, 0.02)

            end)

        else
            if connection then connection:Disconnect() end
            if force then force:Destroy() end
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            UI:Notify("🌍 عادت الجاذبية")
        end
    end)

end