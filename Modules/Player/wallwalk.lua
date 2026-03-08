-- [[ Cryptic Hub - نظام المشي على الجدران المتطور 2D / Advanced 2D Wall Walk ]]
-- المطور: يامي (Yami) | الميزة: تسلق احترافي في جميع الاتجاهات / Feature: Pro climbing in all directions

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local player = game.Players.LocalPlayer
    local isSpidering = false
    local connection = nil

    -- دالة إرسال الإشعارات المزدوجة على شاشة اللعبة / Dual screen notification function
    local function SendScreenNotify(title, text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 4 
            })
        end)
    end

    local function toggleSpider(active)  
        isSpidering = active  
        local char = player.Character  
        local hum = char and char:FindFirstChild("Humanoid")  
        local root = char and char:FindFirstChild("HumanoidRootPart")  

        if isSpidering then  
            connection = RunService.Heartbeat:Connect(function()  
                if not isSpidering or not char or not root then return end  
                  
                -- إطلاق شعاع فحص (Raycast) أمام اللاعب لاكتشاف الجدران / Raycast check
                local rayParam = RaycastParams.new()  
                rayParam.FilterDescendantsInstances = {char}  
                rayParam.FilterType = Enum.RaycastFilterType.Exclude  

                local rayResult = workspace:Raycast(root.Position, root.CFrame.LookVector * 3, rayParam)  

                if rayResult and rayResult.Instance and rayResult.Instance.CanCollide then  
                    local wallNormal = rayResult.Normal  
                      
                    -- إلغاء تأثير الجاذبية أثناء الالتصاق / Nullify gravity
                    root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)  
                      
                    if hum.MoveDirection.Magnitude > 0 then  
                        local moveDir = hum.MoveDirection  
                        root.Velocity = Vector3.new(moveDir.X * 30, moveDir.Y * 50 + 25, moveDir.Z * 30)  
                    else  
                        root.Velocity = Vector3.new(0, 0, 0)  
                    end  
                      
                    root.CFrame = CFrame.new(root.Position, root.Position - wallNormal)  
                end  
            end)  
        else  
            if connection then connection:Disconnect(); connection = nil end  
        end  
    end  

    Tab:AddToggle("تمشي على جدران / Wall Walk", function(active)  
        toggleSpider(active)  
        
        -- إظهار الإشعار المزدوج عند التفعيل فقط (إطفاء صامت) / Activation notification only
        if active then
            SendScreenNotify("Cryptic Hub", "🕷️ تم تفعيل المشي على الجدران.. جرب تسلق المباني الآن!\n🕷️ Wall Walk activated.. Try climbing buildings now!")
        end
    end)  
end
