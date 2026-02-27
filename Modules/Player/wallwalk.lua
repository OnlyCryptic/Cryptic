-- [[ Arwa Hub - ميزة المشي على الجدران (Spider) ]]
-- المطور: Arwa | تجعلك تتسلق وتمشي على أي جدار بمجرد الالتصاق به

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local player = game.Players.LocalPlayer
    local isSpidering = false
    local connection = nil

    local function toggleSpider(active)
        isSpidering = active
        
        if isSpidering then
            -- استخدام Stepped للتعامل مع الفيزياء بشكل دقيق
            connection = RunService.Stepped:Connect(function()
                local char = player.Character
                if not char then return end
                
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                
                if not root or not hum then return end

                -- إطلاق شعاع (Ray) قصير من صدر اللاعب لمعرفة ما إذا كان أمامه جدار
                local rayOrigin = root.Position
                local rayDirection = root.CFrame.LookVector * 2.5 -- مسافة الفحص (مترين ونصف)
                
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {char} -- تجاهل جسم اللاعب نفسه
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                
                local hitResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                
                -- إذا وجد جداراً أمامه
                if hitResult and hitResult.Instance and hitResult.Instance.CanCollide then
                    -- إذا كان اللاعب يحرك الجويستيك (يمشي)
                    if hum.MoveDirection.Magnitude > 0 then
                        -- دفعه للأعلى ليتسلق الجدار
                        root.Velocity = Vector3.new(root.Velocity.X, 40, root.Velocity.Z)
                    else
                        -- إذا توقف عن تحريك الجويستيك، يثبت في مكانه على الجدار ولا يسقط
                        root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                    end
                end
            end)
        else
            -- إيقاف الميزة لتوفير طاقة المعالج
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end

    -- إضافة زر التفعيل في الواجهة
    Tab:AddToggle("🕷️ تسلق/مشي على الجدران (Spider)", function(active)
        toggleSpider(active)
        UI:Notify(active and "تم تفعيل تسلق الجدران.. التصق بأي جدار لتصعده!" or "تم إيقاف تسلق الجدران")
    end)
end
