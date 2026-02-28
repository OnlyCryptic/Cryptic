-- [[ Arwa Hub - ميزات الكاميرا الاحترافية ]]
-- المطور: Arwa | الإصدار المصلح (بدون AddSlider)

return function(Tab, UI)
    local players = game:GetService("Players")
    local runService = game:GetService("RunService")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    -- متغيرات الكاميرا الحرة
    local isFreeCam = false
    local camPart = nil
    local freeCamSpeed = 2

    -- 1. ميزة الكاميرا الحرة
    local function toggleFreeCam(active)
        isFreeCam = active
        if active then
            camPart = Instance.new("Part")
            camPart.Name = "ArwaFreeCamPart"
            camPart.Transparency = 1
            camPart.CanCollide = false
            camPart.Anchored = true
            camPart.CFrame = camera.CFrame
            camPart.Parent = workspace
            camera.CameraSubject = camPart
            
            task.spawn(function()
                while isFreeCam do
                    runService.RenderStepped:Wait()
                    if camPart and lp.Character and lp.Character:FindFirstChild("Humanoid") then
                        local hum = lp.Character.Humanoid
                        if hum.MoveDirection.Magnitude > 0 then
                            camPart.CFrame = camPart.CFrame * CFrame.new(hum.MoveDirection * freeCamSpeed)
                        end
                        camera.CFrame = camPart.CFrame
                    end
                end
            end)
            UI:Notify("✅ تم تفعيل الكاميرا الحرة")
        else
            if camPart then camPart:Destroy() end
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = lp.Character.Humanoid
            end
            UI:Notify("❌ تم إيقاف الكاميرا الحرة")
        end
    end

    Tab:AddToggle("🎥 تشغيل الكاميرا الحرة (Free Cam)", function(active)
        toggleFreeCam(active)
    end)
    
    -- استخدمنا AddInput هنا لأن الواجهة لا تدعم AddSlider
    Tab:AddInput("🚀 سرعة الكاميرا (أرقام فقط)", "اكتبي السرعة هنا مثل 2", function(val)
        local num = tonumber(val)
        if num then
            freeCamSpeed = num
            UI:Notify("تم تغيير السرعة إلى: " .. num)
        end
    end)

    Tab:AddLine()

    -- 2. ميزة اختراق الجدران بالكاميرا (No Camera Clip)
    Tab:AddToggle("👻 اختراق الجدران بالكاميرا (No Clip)", function(active)
        lp.DevCameraOcclusionMode = active and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom
        UI:Notify(active and "الكاميرا الآن تخترق الجدران" or "عادت الكاميرا لوضعها الطبيعي")
    end)

    Tab:AddLine()

    -- 3. ميزة الزوم اللانهائي (No Max Zoom)
    Tab:AddButton("🔍 تفعيل الزوم اللانهائي (No Max Zoom)", function()
        lp.CameraMaxZoomDistance = 1000000
        UI:Notify("✅ يمكنك الآن الزوم لأبعد مسافة ممكنة!")
    end)
end
