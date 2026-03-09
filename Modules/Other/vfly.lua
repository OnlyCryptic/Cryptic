-- [[ Cryptic Hub - Universal Vehicle Fly / طيران المركبات الشامل ]]
-- المطور: يامي (Yami) | الميزة: طيران حر للمركبات مع زر مدمج للسرعة والتفعيل / Universal VFly with compact UI

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    
    local bodyVelocity = nil
    local bodyGyro = nil
    local vflyConnection = nil
    local currentSpeed = 50 -- السرعة الحالية

    -- دالة إرسال الإشعارات المزدوجة / Dual notification function
    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 3
            })
        end)
    end

    -- دالة لتنظيف المحركات (إيقاف الطيران) / Function to clean up movers
    local function CleanVFly()
        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if vflyConnection then vflyConnection:Disconnect(); vflyConnection = nil end
    end

    -- جلب وحدة التحكم الرسمية لدعم عصا تحكم الجوال (Joystick)
    local PlayerModule = require(lp.PlayerScripts:WaitForChild("PlayerModule"))
    local controls = PlayerModule:GetControls()

    -- إضافة الوصف البسيط المزدوج / Adding the short bilingual description
    Tab:AddParagraph("يطير بالسيارات وأي مجسم تقدر تجلس فيه وتتحرك.\nFly with cars or any moving object you can sit in.")

    -- دمج التفعيل والسرعة في زر واحد / Compact toggle & speed control
    Tab:AddSpeedControl("طيران المركبات / Vehicle Fly", function(active, value)
        currentSpeed = value -- تحديث السرعة مباشرة حتى لو كان الطيران شغال
        
        if active then
            -- نتحقق إذا ما كان شغال من قبل عشان ما نكرر الإشعار والمحرك
            if not vflyConnection then
                Notify("Cryptic Hub", "🚗 تم تفعيل طيران المركبات!\n🚗 Vehicle Fly activated!")
                
                vflyConnection = RunService.RenderStepped:Connect(function()
                    local char = lp.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local cam = workspace.CurrentCamera
                    
                    -- التأكد أن اللاعب جالس في مقعد / Check if player is sitting
                    if hum and hum.SeatPart then
                        local seat = hum.SeatPart
                        
                        -- إنشاء المحركات إذا مو موجودة / Create movers if missing
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
                        
                        -- [[ دعم الأجهزة الذكي / Smart Device Support ]]
                        if seat:IsA("VehicleSeat") then
                            local throttle = seat.Throttle -- للأمام والخلف
                            local steer = seat.Steer       -- يمين ويسار
                            moveDir = (cam.CFrame.LookVector * throttle) + (cam.CFrame.RightVector * steer)
                        end
                        
                        if moveDir.Magnitude == 0 then
                            local moveVector = controls:GetMoveVector()
                            moveDir = (cam.CFrame.LookVector * -moveVector.Z) + (cam.CFrame.RightVector * moveVector.X)
                        end
                        
                        -- تطبيق السرعة / Apply Speed
                        if moveDir.Magnitude > 0 then
                            bodyVelocity.Velocity = moveDir.Unit * currentSpeed
                        else
                            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                        end
                    else
                        -- إذا نزل اللاعب، نمسح المحركات عشان ترجع السيارة لطبيعتها
                        -- Clean movers if player jumps out
                        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
                        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
                    end
                end)
            end
        else
            -- إيقاف بصمت بدون إشعار وحذف المحركات / Silent deactivate
            CleanVFly()
        end
    end, 50) -- 50 هي السرعة الافتراضية
    
    Tab:AddLine()
end
