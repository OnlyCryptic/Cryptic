-- [[ Arwa Hub - نظام المشي على الجدران المتطور 2D ]]
-- المطور: Arwa | ميزة: تسلق احترافي في جميع الاتجاهات

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local player = game.Players.LocalPlayer
    local isSpidering = false
    local connection = nil

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

    Tab:AddToggle("🕷️ نظام سبايدر المتطور (Spider 2D)", function(active)
        toggleSpider(active)
        UI:Notify(active and "تم تفعيل المشي المطور.. جرب تسلق المباني الآن!" or "تم إيقاف سبايدر")
    end)
    
    Tab:AddParagraph("هذا الإصدار يسمح لك بالتحرك يميناً ويساراً وللأعلى على الجدران بسلاسة.")
end
