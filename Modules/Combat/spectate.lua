-- [[ Arwa Hub - ميزة الكاميرا الحرة 3D ]]
-- المطور: Arwa | نسخة مبسطة ومستقرة جداً لضمان التحميل

return function(Tab, UI)
    local lp = game:GetService("Players").LocalPlayer
    local runService = game:GetService("RunService")
    local camera = workspace.CurrentCamera
    
    local isFreeCam = false
    local camPart = nil
    local speed = 2 -- السرعة ثابتة لضمان استقرار الكود

    local function toggleFreeCam(active)
        isFreeCam = active
        if active then
            -- إنشاء قطعة وهمية للتحكم بالكاميرا
            camPart = Instance.new("Part")
            camPart.Transparency = 1
            camPart.CanCollide = false
            camPart.Anchored = true
            camPart.CFrame = camera.CFrame
            camPart.Parent = workspace
            camera.CameraSubject = camPart
            
            UI:Notify("✅ تم تفعيل الكاميرا الحرة 3D")
            
            task.spawn(function()
                while isFreeCam do
                    runService.RenderStepped:Wait()
                    if camPart and lp.Character and lp.Character:FindFirstChild("Humanoid") then
                        local hum = lp.Character.Humanoid
                        -- نظام طيران 3D: يتحرك في اتجاه نظرة الكاميرا
                        if hum.MoveDirection.Magnitude > 0 then
                            local lookVector = camera.CFrame.LookVector
                            local moveDir = hum.MoveDirection
                            
                            -- دمج اتجاه الحركة مع نظرة الكاميرا للطيران في كل الاتجاهات
                            camPart.CFrame = camPart.CFrame * CFrame.new(moveDir * speed)
                        end
                        camera.CFrame = camPart.CFrame
                    end
                end
            end)
        else
            -- إرجاع الكاميرا لوضعها الطبيعي
            if camPart then camPart:Destroy() end
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lp.Character.Humanoid
            end
            UI:Notify("❌ تم إيقاف الكاميرا الحرة")
        end
    end

    -- زر تشغيل وإيقاف بسيط لضمان عدم حدوث أخطاء
    Tab:AddToggle("🎥 تشغيل الكاميرا الحرة (Free Cam 3D)", function(active)
        toggleFreeCam(active)
    end)
end
