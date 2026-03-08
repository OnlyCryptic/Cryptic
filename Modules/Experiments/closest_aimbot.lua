-- [[ Cryptic Hub - أيم بوت الجسم المطور / Advanced Body Aimbot ]]
-- المطور: يامي (Yami) | التحديث: تثبيت فوري على الجسم + دعم الجوال والبي سي
-- Features: Instant Body Lock, Mobile & PC Support, Dual Language, Silent Off

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- [[ الإعدادات / Config ]]
    local Config = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        -- سرعة التتبع (1 تعني فوري، 0.1 تعني ناعم جداً)
        Smoothness = 0.4, 
        FOV = 120,
        TargetPart = "HumanoidRootPart" -- التثبيت على الجسم
    }

    -- [[ دائرة المدى / FOV Circle ]]
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 60
    FOVCircle.Radius = Config.FOV
    FOVCircle.Filled = false
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.fromRGB(0, 255, 150)
    FOVCircle.Transparency = 0.7

    -- دالة الإشعارات المزدوجة / Dual Notification
    local function Notify(ar, en)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 4
            })
        end)
    end

    -- فحص الرؤية (الجدران) / Wall Check
    local function isVisible(targetPart)
        if not Config.WallCheck then return true end
        local castPoints = {Camera.CFrame.Position, targetPart.Position}
        local ignoreList = {LocalPlayer.Character, targetPart.Parent}
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = ignoreList
        params.FilterType = Enum.RaycastFilterType.Exclude

        local raycastResult = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000, params)
        return raycastResult == nil
    end

    -- البحث عن أقرب هدف لمنتصف الشاشة (مناسب للجوال والبي سي)
    local function getClosestTarget()
        local closest = nil
        local shortestDist = Config.FOV
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Config.TargetPart) then
                -- فحص الفريق
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

    -- [[ الزر الرئيسي / Toggle Button ]]
    Tab:AddToggle("أيم بوت الجسم / Body Aimbot", function(state)
        Config.Enabled = state
        FOVCircle.Visible = state

        if state then
            Notify("🎯 تم تفعيل أيم بوت الجسم (تثبيت فوري)", "🎯 Body Aimbot Activated (Instant Lock)")
        else
            -- إيقاف صامت / Silent Off
        end
    end)

    -- [[ محرك التشغيل / Main Engine ]]
    RunService.RenderStepped:Connect(function()
        if Config.Enabled then
            -- تحديث الدائرة في منتصف الشاشة دائماً
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            
            local target = getClosestTarget()
            if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- توجيه الكاميرا فورياً وبدقة نحو الجسم
                local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
                
                -- دعم الشيفت لوك التلقائي للجسم
                local root = LocalPlayer.Character.HumanoidRootPart
                local lookAt = Vector3.new(target.Position.X, root.Position.Y, target.Position.Z)
                root.CFrame = root.CFrame:Lerp(CFrame.new(root.Position, lookAt), 0.3)
            end
        end
    end)
end
