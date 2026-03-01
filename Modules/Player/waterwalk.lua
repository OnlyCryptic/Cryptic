-- [[ Cryptic Hub - المشي على الماء المطور ]]
-- المطور: Cryptic | الميزة: التعرف على كافة أنواع المياه

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    
    local isWaterWalking = false
    local waterPlatform = Instance.new("Part")
    
    -- إعداد المنصة
    waterPlatform.Name = "CrypticWaterPart"
    waterPlatform.Size = Vector3.new(20, 1, 20) -- تكبير حجم المنصة لثبات أكثر
    waterPlatform.Transparency = 1
    waterPlatform.Anchored = true
    waterPlatform.CanCollide = false
    waterPlatform.Parent = workspace

    Tab:AddToggle("🌊 المشي على الماء (Water Walk)", function(active)
        isWaterWalking = active
        if active then
            UI:Notify("✅ تم تفعيل الكاشف العالمي للماء في Cryptic Hub")
        else
            waterPlatform.CanCollide = false
            UI:Notify("❌ تم إيقاف الميزة")
        end
    end)

    runService.Heartbeat:Connect(function()
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if isWaterWalking and root then
            -- زيادة طول شعاع البحث لـ 20 مسمار لضمان التعرف
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = {char, waterPlatform}
            
            local ray = workspace:Raycast(root.Position, Vector3.new(0, -20, 0), raycastParams)
            
            -- كاشف ذكي: يتعرف على مادة الماء أو أي قطعة تسمى "Water"
            local isDetected = false
            if ray then
                if ray.Material == Enum.Material.Water or ray.Instance.Name:lower():find("water") then
                    isDetected = true
                end
            end

            if isDetected then
                waterPlatform.CanCollide = true
                -- وضع المنصة تحت اللاعب بالضبط
                waterPlatform.CFrame = CFrame.new(root.Position.X, ray.Position.Y + 0.9, root.Position.Z)
            else
                waterPlatform.CanCollide = false
            end
        else
            waterPlatform.CanCollide = false
        end
    end)
end
