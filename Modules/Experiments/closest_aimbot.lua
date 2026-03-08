-- [[ Cryptic Hub - نظام الاستهداف التجريبي (Aimbot Body) ]]
-- المطور: أروى (Arwa) | التحديث: تثبيت فوري على الجسم + دعم جميع المنصات
-- Note: This is an internal experiment module (Developer Only)

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- [[ الإعدادات / Config ]]
    local Config = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        Smoothness = 0.45, -- سرعة التثبيت (كلما زاد الرقم زادت السرعة)
        FOV = 150,
        TargetPart = "HumanoidRootPart" -- استهداف الجسم مباشرة
    }

    -- [[ دائرة المدى / FOV Visual ]]
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 60
    FOVCircle.Radius = Config.FOV
    FOVCircle.Filled = false
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.fromRGB(0, 255, 150)
    FOVCircle.Transparency = 0.6

    -- دالة الإشعارات المزدوجة (تظهر عند التفعيل فقط)
    local function Notify(ar, en)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub [Exp]",
                Text = ar .. "\n" .. en,
                Duration = 4
            })
        end)
    end

    -- فحص الرؤية (الجدران)
    local function isVisible(targetPart)
        if not Config.WallCheck then return true end
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000, params)
        return result == nil
    end

    -- البحث عن أقرب هدف لمركز الشاشة (مثالي للجوال والبي سي)
    local function getClosestTarget()
        local closest = nil
        local shortestDist = Config.FOV
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Config.TargetPart) then
                if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
                
                local targetPart = player.Character[Config.TargetPart]
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if dist < shortestDist then
                        if isVisible(targetPart) then
                            closest = targetPart
                            shortestDist = dist
                        end
                    end
                end
            end
        end
        return closest
    end

    -- إضافة الزر للواجهة
    Tab:AddToggle("أيم بوت تجريبي / Exp Aimbot", function(state)
        Config.Enabled = state
        FOVCircle.Visible = state
        
        if state then
            Notify("🎯 تم تفعيل أيم بوت الجسم التجريبي", "🎯 Experimental Body Aimbot Activated")
        end
        -- إيقاف صامت: لا يوجد إشعار عند الـ else
    end)

    -- محرك التشغيل الرئيسي
    RunService.RenderStepped:Connect(function()
        if Config.Enabled then
            -- تحديث موقع الدائرة في منتصف الشاشة دائماً
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            
            local target = getClosestTarget()
            if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- توجيه الكاميرا
                local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
                
                -- توجيه الشخصية (Shift Lock تلقائي للهدف)
                local root = LocalPlayer.Character.HumanoidRootPart
                local lookAt = Vector3.new(target.Position.X, root.Position.Y, target.Position.Z)
                root.CFrame = root.CFrame:Lerp(CFrame.new(root.Position, lookAt), 0.3)
            end
        end
    end)
end
