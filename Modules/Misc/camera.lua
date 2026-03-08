-- [[ Cryptic Hub - FreeCam Mobile V8 ]]
-- المطور: يامي (Yami) | التحديث: إشعار تفعيل فقط + ترجمة مزدوجة / Update: Activation notify only + Dual language

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local cam = workspace.CurrentCamera

    local isFreeCam = false
    local flySpeed = 80
    local yaw, pitch = 0, 0
    local targetYaw, targetPitch = 0, 0
    local camPos
    local sensitivity = 0.40
    local smoothness = 0.18

    -- دالة الإشعارات المزدوجة / Dual notification function
    local function Notify(arText, enText)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 4
            })
        end)
    end

    local function toggleFreeCam(active, speedValue)
        isFreeCam = active
        flySpeed = speedValue

        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if isFreeCam and root and hum then
            -- إعدادات التفعيل / Activation settings
            root.Anchored = true
            hum.PlatformStand = true
            hum.AutoRotate = false

            cam.CameraType = Enum.CameraType.Scriptable
            camPos = cam.CFrame.Position

            -- إشعار التفعيل المزدوج فقط / Activation notify only
            Notify("🎥 تم تفعيل الكاميرا الحرة V8", "🎥 FreeCam V8 activated!")

            -- نظام التحكم باللمس للجوال / Mobile touch control system
            UIS.InputChanged:Connect(function(input)
                if not isFreeCam then return end
                if input.UserInputType == Enum.UserInputType.Touch then
                    targetYaw = targetYaw - input.Delta.X * sensitivity
                    targetPitch = targetPitch - input.Delta.Y * sensitivity
                    targetPitch = math.clamp(targetPitch, -85, 85)
                end
            end)

            -- محرك الحركة السلسة / Smooth movement engine
            RunService:BindToRenderStep("FreeCamV8", Enum.RenderPriority.Camera.Value + 1, function(dt)
                yaw = yaw + (targetYaw - yaw) * smoothness
                pitch = pitch + (targetPitch - pitch) * smoothness

                local rotation = CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
                local moveDir = hum.MoveDirection
                local moveVector = Vector3.zero

                if moveDir.Magnitude > 0 then
                    local forward = rotation.LookVector
                    local right = rotation.RightVector
                    
                    local zInput = moveDir.Z -- استخدام اتجاه الجويستيك مباشرة
                    local xInput = moveDir.X
                    
                    moveVector = (forward * -zInput) + (right * xInput)
                end

                if moveVector.Magnitude > 0 then
                    camPos = camPos + moveVector.Unit * flySpeed * dt
                end
                cam.CFrame = CFrame.new(camPos) * rotation
            end)
        else
            -- إيقاف الميزة بصمت / Silent deactivation
            RunService:UnbindFromRenderStep("FreeCamV8")
            if root then root.Anchored = false end
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
            end
            cam.CameraType = Enum.CameraType.Custom
        end
    end

    -- إضافة التحكم للواجهة / Add control to UI
    Tab:AddSpeedControl("كاميرا حرة / FreeCam", function(active, value)
        toggleFreeCam(active, value)
    end, 80)
end
