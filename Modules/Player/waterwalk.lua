-- [[ Cryptic Hub - ميزة المشي على الماء ]]
-- المطور: Cryptic | الميزة: إنشاء سطح صلب فوق الماء تلقائياً

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    
    local isWaterWalking = false
    local waterPlatform = Instance.new("Part")
    
    -- إعداد المنصة المخفية
    waterPlatform.Name = "CrypticWaterPart"
    waterPlatform.Size = Vector3.new(10, 1, 10)
    waterPlatform.Transparency = 1
    waterPlatform.Anchored = true
    waterPlatform.CanCollide = false
    waterPlatform.Parent = workspace

    Tab:AddToggle("🌊 المشي على الماء (Water Walk)", function(active)
        isWaterWalking = active
        if active then
            UI:Notify("✅ تم تفعيل المشي على الماء في Cryptic Hub")
        else
            waterPlatform.CanCollide = false
            UI:Notify("❌ تم إيقاف الميزة")
        end
    end)

    runService.Heartbeat:Connect(function()
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if isWaterWalking and root and hum then
            -- البحث عن مستوى الماء أو الأرض تحت اللاعب
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = {char, waterPlatform}
            
            local ray = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), raycastParams)
            
            -- إذا كان اللاعب فوق الماء مباشرة
            if ray and ray.Material == Enum.Material.Water then
                waterPlatform.CanCollide = true
                -- وضع المنصة تحت قدم اللاعب بالضبط عند مستوى سطح الماء
                waterPlatform.CFrame = CFrame.new(root.Position.X, ray.Position.Y + 0.9, root.Position.Z)
            else
                -- إلغاء التصادم إذا لم يكن هناك ماء لكي لا تعيق حركتك العادية
                waterPlatform.CanCollide = false
            end
        else
            waterPlatform.CanCollide = false
        end
    end)
end
