-- [[ Cryptic Hub - Universal Vehicle Fly / طيران المركبات الشامل ]]
-- المطور: يامي (Yami) | الميزة: طيران حر مع كاميرا تخترق الجدران (No Camera Clip)

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    
    local bodyVelocity = nil
    local bodyGyro = nil
    local vflyConnection = nil
    local currentSpeed = 50 
    local originalOcclusion = lp.DevCameraOcclusionMode -- لحفظ إعدادات الكاميرا الأصلية

    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 3
            })
        end)
    end

    local function CleanVFly()
        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if vflyConnection then vflyConnection:Disconnect(); vflyConnection = nil end
        
        -- إرجاع الكاميرا لوضعها الطبيعي عند الإيقاف
        pcall(function()
            lp.DevCameraOcclusionMode = originalOcclusion or Enum.DevCameraOcclusionMode.Zoom
        end)
    end

    local PlayerModule = require(lp.PlayerScripts:WaitForChild("PlayerModule"))
    local controls = PlayerModule:GetControls()

    Tab:AddSpeedControl("طيران المركبات / Vehicle Fly", function(active, value)
        currentSpeed = value 
        
        if active then
            if not vflyConnection then
                Notify("Cryptic Hub", "🚗 تم تفعيل طيران المركبات!\n🚗 Vehicle Fly activated!")
                
                -- تفعيل الكاميرا اللي تخترق الجدران (Invisicam)
                pcall(function()
                    originalOcclusion = lp.DevCameraOcclusionMode
                    lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
                end)
                
                vflyConnection = RunService.RenderStepped:Connect(function()
                    local char = lp.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local cam = workspace.CurrentCamera
                    
                    if hum and hum.SeatPart then
                        local seat = hum.SeatPart
                        
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
                        
                        if seat:IsA("VehicleSeat") then
                            local throttle = seat.Throttle
                            local steer = seat.Steer
                            moveDir = (cam.CFrame.LookVector * throttle) + (cam.CFrame.RightVector * steer)
                        end
                        
                        if moveDir.Magnitude == 0 then
                            local moveVector = controls:GetMoveVector()
                            moveDir = (cam.CFrame.LookVector * -moveVector.Z) + (cam.CFrame.RightVector * moveVector.X)
                        end
                        
                        if moveDir.Magnitude > 0 then
                            bodyVelocity.Velocity = moveDir.Unit * currentSpeed
                        else
                            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                        end
                    else
                        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
                        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
                    end
                end)
            end
        else
            CleanVFly()
        end
    end, 50) 
    
    Tab:AddLine()
end
