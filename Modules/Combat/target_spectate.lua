-- [[ Cryptic Hub - ميزة مراقبة الهدف (Spectate) ]]
-- المطور: يامي (Yami) | الميزات: تتبع تلقائي للكاميرا، عودة سريعة، إشعارات 25 ثانية

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    local isSpectating = false

    -- دالة إشعارات روبلوكس الرسمية (مدة 25 ثانية)
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 10, 
            })
        end)
    end

    -- [[ زر التشغيل بالاسم الموحد ]]
    Tab:AddToggle("مراقبة الهدف / Spectate", function(active)
        isSpectating = active
        
        if active then
            -- التأكد من وجود هدف في خانة البحث (ArwaTarget)
            if _G.ArwaTarget and _G.ArwaTarget.Character then
                local hum = _G.ArwaTarget.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    camera.CameraSubject = hum
                    SendRobloxNotification("Cryptic Hub", "👁️ جاري مراقبة: " .. _G.ArwaTarget.DisplayName)
                end
            else
                isSpectating = false
                SendRobloxNotification("Cryptic Hub", "⚠️ حدد لاعباً أولاً لمراقبته!")
            end
        else
            -- إرجاع الكاميرا لشخصيتك فوراً عند الإيقاف
            if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                camera.CameraSubject = lp.Character:FindFirstChildOfClass("Humanoid")
            end
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف المراقبة والعودة لشخصيتك.")
        end
    end)

    -- [[ حلقة التحديث لضمان بقاء الكاميرا مع الهدف ]]
    runService.RenderStepped:Connect(function()
        if isSpectating then
            local target = _G.ArwaTarget
            if target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
                -- قفل الكاميرا على الشخصية المستهدفة باستمرار
                camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
            else
                -- إذا خرج اللاعب أو مات، ترجع الكاميرا لك تلقائياً عشان ما تعلق الرؤية
                if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                    camera.CameraSubject = lp.Character:FindFirstChildOfClass("Humanoid")
                end
            end
        end
    end)
end
