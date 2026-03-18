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
    
    -- تم تعديل هذه القيم لتناسب شاشات الهواتف بشكل أفضل
    local sensitivity = 0.45 
    local smoothness = 0.40 

    local touchConn -- متغير لحفظ اتصال اللمس لمنع تداخل الأوامر

    -- دالة الإشعارات المزدوجة (عربي/انجليزي)
    local function SendScreenNotify(arText, enText)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 3
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
            root.Anchored = true
            hum.PlatformStand = true
            hum.AutoRotate = false

            cam.CameraType = Enum.CameraType.Scriptable
            camPos = cam.CFrame.Position
            
            -- أخذ زاوية الكاميرا الحالية لمنع الالتفاف المفاجئ عند التفعيل
            local cx, cy, cz = cam.CFrame:ToOrientation()
            yaw = math.deg(cy)
            pitch = math.deg(cx)
            targetYaw = yaw
            targetPitch = pitch

            -- إشعار التفعيل المزدوج
            SendScreenNotify("🎥 تم تفعيل الكاميرا الحرة V8", "🎥 FreeCam V8 Activated")

            -- تنظيف أي اتصال لمس قديم
            if touchConn then touchConn:Disconnect() end

            touchConn = UIS.InputChanged:Connect(function(input, gameProcessed)
                if not isFreeCam then return end
                -- تجاهل اللمس إذا كان على جويستيك الحركة أو أزرار الـ UI
                if gameProcessed then return end 

                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                    targetYaw = targetYaw - input.Delta.X * sensitivity
                    targetPitch = targetPitch - input.Delta.Y * sensitivity
                    targetPitch = math.clamp(targetPitch, -85, 85)
                end
            end)

            RunService:BindToRenderStep("FreeCamV8", Enum.RenderPriority.Camera.Value + 1, function(dt)
                yaw = yaw + (targetYaw - yaw) * smoothness
                pitch = pitch + (targetPitch - pitch) * smoothness

                local rotation = CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
                local moveDir = hum.MoveDirection
                local moveVector = Vector3.zero

                if moveDir.Magnitude > 0 then
                    local forward = rotation.LookVector
                    local right = rotation.RightVector
                    local flatForward = Vector3.new(forward.X, 0, forward.Z)
                    if flatForward.Magnitude > 0 then flatForward = flatForward.Unit end
                    local flatRight = Vector3.new(right.X, 0, right.Z)
                    if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

                    local zInput = moveDir:Dot(flatForward)
                    local xInput = moveDir:Dot(flatRight)
                    moveVector = (forward * zInput) + (right * xInput)
                end

                if moveVector.Magnitude > 0 then
                    camPos = camPos + moveVector.Unit * flySpeed * dt
                end
                cam.CFrame = CFrame.new(camPos) * rotation
            end)
        else
            -- إيقاف الميزة بصمت وإعادة الشخصية لطبيعتها
            RunService:UnbindFromRenderStep("FreeCamV8")
            if touchConn then 
                touchConn:Disconnect() 
                touchConn = nil
            end
            
            if root then root.Anchored = false end
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
            end
            cam.CameraType = Enum.CameraType.Custom
        end
    end

    Tab:AddSpeedControl("كاميرا حرة / FreeCam", function(active, value)
        toggleFreeCam(active, value)
    end, 80)
end
