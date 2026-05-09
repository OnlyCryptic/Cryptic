-- [[ Cryptic Hub - نظام الاستهداف المطور (Super Lock) ]]
-- المطور: أروى (Arwa) | التحديث: تثبيت تلقائي على أقرب مسافة + دعم كامل للجوال
-- Note: Simplified logic to ensure it works on all executors.

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- [[ الإعدادات / Config ]]
    local Config = {
        Enabled = false,
        TeamCheck = true,
        -- سرعة التثبيت (1 يعني فوري جداً، 0.5 يعني نص سريع)
        Smoothness = 0.8, 
        -- خليت المدى كبير جداً عشان يصيد أي واحد قريب منك
        MaxDistance = 1000, 
        TargetPart = "HumanoidRootPart"
    }

    local function Notify(ar, en)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub [Exp]",
                Text = ar .. "\n" .. en,
                Duration = 4
            })
        end)
    end

    -- دالة البحث عن أقرب لاعب لجسمك (أضمن طريقة للأيم بوت)
    local function getClosestPlayer()
        local closest = nil
        local shortestDist = Config.MaxDistance
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if not myRoot then return nil end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Config.TargetPart) then
                -- فحص الفريق
                if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
                
                local targetRoot = player.Character[Config.TargetPart]
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

                -- التأكد أن اللاعب حي
                if humanoid and humanoid.Health > 0 then
                    local dist = (targetRoot.Position - myRoot.Position).Magnitude
                    
                    if dist < shortestDist then
                        closest = targetRoot
                        shortestDist = dist
                    end
                end
            end
        end
        return closest
    end

    -- إضافة الزر
    Tab:AddToggle("أيم بوت تجريبي / Exp Aimbot", function(state)
        Config.Enabled = state
        if state then
            Notify("🎯 تم تفعيل التثبيت التلقائي (الأقرب للجسم)", "🎯 Auto-Lock Activated (Closest to Body)")
        end
    end)

    -- محرك التتبع
    RunService.RenderStepped:Connect(function()
        if not Config.Enabled then return end
        
        local target = getClosestPlayer()
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

        if target and myRoot then
            -- 1. توجيه الكاميرا فورياً للهدف
            local targetPos = target.Position
            local camCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(camCFrame, Config.Smoothness)
            
            -- 2. توجيه جسمك للهدف (Shift Lock)
            local lookAt = Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z)
            myRoot.CFrame = myRoot.CFrame:Lerp(CFrame.new(myRoot.Position, lookAt), 0.5)
        end
    end)
end
