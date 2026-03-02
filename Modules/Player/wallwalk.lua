-- [[ Cryptic Hub - نظام المشي على الجدران المتطور 2D ]]
-- المطور: Cryptic | ميزة: تسلق احترافي في جميع الاتجاهات

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local player = game.Players.LocalPlayer
    local isSpidering = false
    local connection = nil

    -- دالة إرسال الإشعارات على شاشة اللعبة مباشرة
    local function SendScreenNotify(title, text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 3 -- مدة بقاء الإشعار
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
                  
                -- إطلاق شعاع فحص (Raycast) أمام اللاعب لاكتشاف الجدران  
                local rayParam = RaycastParams.new()  
                rayParam.FilterDescendantsInstances = {char}  
                rayParam.FilterType = Enum.RaycastFilterType.Exclude  

                local rayResult = workspace:Raycast(root.Position, root.CFrame.LookVector * 3, rayParam)  

                if rayResult and rayResult.Instance and rayResult.Instance.CanCollide then  
                    -- حساب اتجاه الجدار (Normal) لجعل الشخصية تلتصق به بشكل 2D  
                    local wallNormal = rayResult.Normal  
                      
                    -- إلغاء تأثير الجاذبية أثناء الالتصاق بالجدار  
                    root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)  
                      
                    if hum.MoveDirection.Magnitude > 0 then  
                        -- نظام الحركة المطور: يحول حركة الجويستيك لتناسب سطح الجدار  
                        local moveDir = hum.MoveDirection  
                        root.Velocity = Vector3.new(moveDir.X * 30, moveDir.Y * 50 + 25, moveDir.Z * 30)  
                    else  
                        -- الثبات التام (Sticky) عند التوقف عن الحركة  
                        root.Velocity = Vector3.new(0, 0, 0)  
                    end  
                      
                    -- إجبار الشخصية على مواجهة الجدار دائماً بشكل احترافي  
                    root.CFrame = CFrame.new(root.Position, root.Position - wallNormal)  
                end  
            end)  
        else  
            if connection then connection:Disconnect(); connection = nil end  
        end  
    end  

    Tab:AddToggle("تمشي على جدران", function(active)  
        toggleSpider(active)  
        
        -- إظهار الإشعار في شاشة روبلوكس
        if active then
            SendScreenNotify("Cryptic Hub", "🕷️ تم تفعيل المشي على الجدران.. جرب تسلق المباني الآن!")
        else
            SendScreenNotify("Cryptic Hub", "🛑 تم إيقاف المشي على الجدران.")
        end
    end)  
end
