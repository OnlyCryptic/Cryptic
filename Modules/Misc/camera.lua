-- [[ Arwa Hub - ميزة الكاميرا الحرة 3D ]]
-- النسخة النهائية الصافية لضمان عدم تعليق السكربت

return function(Tab, UI)
    local lp = game:GetService("Players").LocalPlayer
    local runService = game:GetService("RunService")
    local camera = workspace.CurrentCamera
    
    local isFreeCam = false
    local camPart = nil
    local speed = 2

    local function toggleFreeCam(active)
        isFreeCam = active
        if active then
            camPart = Instance.new("Part")
            camPart.Name = "ArwaFreeCam"
            camPart.Transparency = 1
            camPart.CanCollide = false
            camPart.Anchored = true
            camPart.CFrame = camera.CFrame
            camPart.Parent = workspace
            camera.CameraSubject = camPart
            UI:Notify("✅ تم تفعيل الكاميرا الحرة")
            
            task.spawn(function()
                while isFreeCam do
                    runService.RenderStepped:Wait()
                    if camPart and lp.Character and lp.Character:FindFirstChild("Humanoid") then
                        local hum = lp.Character.Humanoid
                        if hum.MoveDirection.Magnitude > 0 then
                            camPart.CFrame = camPart.CFrame * CFrame.new(hum.MoveDirection * speed)
                        end
                        camera.CFrame = camPart.CFrame
                    end
                end
            end)
        else
            if camPart then camPart:Destroy() end
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lp.Character.Humanoid
            end
            UI:Notify("❌ تم إيقاف الكاميرا الحرة")
        end
    end

    -- نستخدم Toggle فقط لضمان الأمان والتحميل الكامل
    Tab:AddToggle("🎥 تشغيل الكاميرا الحرة (Free Cam 3D)", function(active)
        toggleFreeCam(active)
    end)
end
