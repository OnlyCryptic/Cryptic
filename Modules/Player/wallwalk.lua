-- [[ Cryptic Hub - Wall Walk (Spider) Module ]]
-- المطور: يامي (Yami) | التحديث: تسلق الجدران بسلاسة باستخدام Raycast

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local wallWalkConnection = nil

    Tab:AddToggle("المشي على الجدران / Wall Walk", function(state)
        if state then
            -- نستخدم RenderStepped لضمان استجابة سريعة جداً عند ملامسة الجدار
            wallWalkConnection = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if char and hrp and hum then
                    -- 1. إعداد شعاع الفحص (Raycast) للبحث عن جدار أمام اللاعب مباشرة
                    local rayOrigin = hrp.Position
                    local rayDirection = hrp.CFrame.LookVector * 2.5 -- يفحص مسافة 2.5 أمام اللاعب
                    
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {char} -- تجاهل جسم اللاعب نفسه
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    
                    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                    
                    -- 2. إذا اصطدم الشعاع بجدار، وكان اللاعب يضغط على زر المشي
                    if result and hum.MoveDirection.Magnitude > 0 then
                        -- نلغي الجاذبية مؤقتاً ونعطيه قوة دفع للأعلى تعادل سرعة مشيه (أو أسرع قليلاً)
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, hum.WalkSpeed * 1.5, hrp.Velocity.Z)
                        
                        -- تغيير حالة اللاعب لمنع أنميشن السقوط المزعج
                        if hum:GetState() ~= Enum.HumanoidStateType.Climbing then
                            hum:ChangeState(Enum.HumanoidStateType.Climbing)
                        end
                    end
                end
            end)
        else
            -- حالة الإيقاف: فصل الاتصال وإرجاع اللاعب لطبيعته
            if wallWalkConnection then
                wallWalkConnection:Disconnect()
                wallWalkConnection = nil
            end
            
            -- التأكد من إرجاع حالة اللاعب للطبيعة إذا تم إيقاف الميزة وهو يتسلق
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() == Enum.HumanoidStateType.Climbing then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end)
end
