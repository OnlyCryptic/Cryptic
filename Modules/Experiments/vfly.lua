-- [[ Cryptic Hub - Universal Vehicle Fly / طيران المركبات الشامل ]]
-- المطور: يامي (Yami) | الميزة: يدعم الجوال، الكمبيوتر، وجميع الأجهزة

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer
    
    local isVFlyEnabled = false
    local vflySpeed = 50
    local bodyVelocity = nil
    local bodyGyro = nil
    local vflyConnection = nil

    -- جلب وحدة التحكم الرسمية لدعم عصا تحكم الجوال (Joystick)
    local PlayerModule = require(lp.PlayerScripts:WaitForChild("PlayerModule"))
    local controls = PlayerModule:GetControls()

    -- دالة لتنظيف المحركات (إيقاف الطيران)
    local function CleanVFly()
        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if vflyConnection then vflyConnection:Disconnect(); vflyConnection = nil end
    end

    Tab:AddInput("سرعة المركبة | VFly Speed", "اكتب السرعة (مثال: 50)", function(text)
        local num = tonumber(text)
        if num then
            vflySpeed = num
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = "تم تغيير السرعة إلى | Speed set to: " .. tostring(num), Duration = 3
            })
        end
    end)

    Tab:AddToggle("طيران المركبات | Vehicle Fly", function(state)
        isVFlyEnabled = state
        
        if state then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = "🚗 تم تفعيل طيران المركبات | VFly Enabled", Duration = 3
            })
            
            vflyConnection = RunService.RenderStepped:Connect(function()
                local char = lp.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local cam = workspace.CurrentCamera
                
                -- التأكد أن اللاعب جالس في مقعد
                if hum and hum.SeatPart then
                    local seat = hum.SeatPart
                    
                    -- إنشاء المحركات إذا مو موجودة
                    if not bodyVelocity or not bodyVelocity.Parent then
                        bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bodyVelocity.Parent = seat
                    end
                    if not bodyGyro or not bodyGyro.Parent then
                        bodyGyro = Instance.new("BodyGyro")
                        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        bodyGyro.P = 9000
                        bodyGyro.Parent = seat
                    end
                    
                    bodyGyro.CFrame = cam.CFrame
                    local moveDir = Vector3.new(0, 0, 0)
                    
                    -- [[ دعم الأجهزة الذكي ]]
                    -- 1. إذا كان المقعد من نوع مقعد سيارة (VehicleSeat) يدعم أزرار الجوال والكمبيوتر
                    if seat:IsA("VehicleSeat") then
                        local throttle = seat.Throttle -- يعطي 1 للأمام و -1 للخلف
                        local steer = seat.Steer       -- يعطي 1 لليمين و -1 لليسار
                        moveDir = (cam.CFrame.LookVector * throttle) + (cam.CFrame.RightVector * steer)
                    end
                    
                    -- 2. إذا كان مقعد عادي أو الماب مغير النظام، نستخدم عصا الجوال/أزرار الـ PC
                    if moveDir.Magnitude == 0 then
                        local moveVector = controls:GetMoveVector()
                        -- الـ Z سالب للأمام، والـ X لليمين
                        moveDir = (cam.CFrame.LookVector * -moveVector.Z) + (cam.CFrame.RightVector * moveVector.X)
                    end
                    
                    -- تطبيق السرعة
                    if moveDir.Magnitude > 0 then
                        bodyVelocity.Velocity = moveDir.Unit * vflySpeed
                    else
                        bodyVelocity.Velocity = Vector3.new(0, 0, 0) -- يوقف السيارة في الهواء إذا ما تحركت
                    end
                else
                    -- إذا نزل اللاعب من السيارة، نمسح المحركات عشان ما تعلق بالهواء
                    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
                    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
                end
            end)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = "❌ تم الإيقاف | VFly Disabled", Duration = 3
            })
            CleanVFly()
        end
    end)
    
    Tab:AddLine()
end
