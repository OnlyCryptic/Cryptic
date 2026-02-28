-- [[ Arwa Hub - ميزة الكاميرا الحرة المصلحة ]]
-- المطور: Arwa | الميزات: تثبيت اللاعب + حركة 3D كاملة باتجاه النظر

return function(Tab, UI)
    local lp = game:GetService("Players").LocalPlayer
    local runService = game:GetService("RunService")
    local camera = workspace.CurrentCamera
    
    local isFreeCam = false
    local camPart = nil
    local speed = 2

    local function toggleFreeCam(active)
        isFreeCam = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if active and root and hum then
            -- 1. تثبيت اللاعب في مكانه لكي لا يتحرك مع الجويستيك
            root.Anchored = true
            
            -- 2. إنشاء قطعة الكاميرا الحرة
            camPart = Instance.new("Part")
            camPart.Name = "ArwaFreeCam"
            camPart.Transparency = 1
            camPart.CanCollide = false
            camPart.Anchored = true
            camPart.CFrame = camera.CFrame
            camPart.Parent = workspace
            
            camera.CameraSubject = camPart
            UI:Notify("✅ تم تفعيل الكاميرا الحرة (اللاعب ثابت)")
            
            task.spawn(function()
                while isFreeCam do
                    runService.RenderStepped:Wait()
                    if camPart and hum.MoveDirection.Magnitude > 0 then
                        -- نظام الحركة 3D الاحترافي:
                        -- نأخذ اتجاه نظرة الكاميرا (LookVector) ونضربه في حركة الجويستيك
                        local lookVector = camera.CFrame.LookVector
                        local rightVector = camera.CFrame.RightVector
                        local moveDir = hum.MoveDirection
                        
                        -- حساب الاتجاه الجديد بناءً على أين تنظر الكاميرا حالياً
                        local finalVec = (lookVector * -moveDir.Z) + (rightVector * moveDir.X)
                        
                        camPart.CFrame = camPart.CFrame + (finalVec * speed)
                    end
                    -- جعل الكاميرا تتبع القطعة دائماً
                    if camPart then
                        camera.CFrame = CFrame.new(camPart.Position) * (camera.CFrame - camera.CFrame.Position)
                    end
                end
            end)
        else
            -- إرجاع كل شيء لوضعه الطبيعي
            if root then root.Anchored = false end -- فك تثبيت اللاعب
            if camPart then camPart:Destroy() end
            if hum then camera.CameraSubject = hum end
            UI:Notify("❌ عاد التحكم للاعب")
        end
    end

    Tab:AddToggle("🎥 الكاميرا الحرة", function(active)
        toggleFreeCam(active)
    end)
end
