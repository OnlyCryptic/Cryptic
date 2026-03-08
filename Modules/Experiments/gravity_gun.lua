-- [[ Cryptic Hub - مسدس الجاذبية (Gravity Gun FE) ]]
-- المطور: يامي (Yami) | الوصف: سحب البلوكات وإطلاقها كقذائف مدمرة!

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    local mouse = lp:GetMouse()
    local cam = workspace.CurrentCamera

    local tool = nil
    local heldPart = nil
    local bp, bg = nil, nil
    local updateConnection = nil

    local function SendRobloxNotification(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 }) end)
    end

    -- دالة إفلات البلوكة
    local function releasePart()
        if heldPart then
            if bp then bp:Destroy() end
            if bg then bg:Destroy() end
            pcall(function() heldPart.Massless = false end)
            heldPart = nil
        end
    end

    Tab:AddToggle("مسدس الجاذبية / Gravity Gun", function(state)
        if state then
            -- إنشاء الأداة في حقيبة اللاعب
            tool = Instance.new("Tool")
            tool.Name = "مسدس الجاذبية 🔫"
            tool.RequiresHandle = false
            tool.CanBeDropped = false
            tool.Parent = lp.Backpack

            SendRobloxNotification("Cryptic Hub", "🔫 تم إضافة مسدس الجاذبية لحقيبتك! (اضغط للسحب ثم اضغط للإطلاق)")

            -- نظام السحب والإطلاق عند الضغط
            tool.Activated:Connect(function()
                if not heldPart then
                    -- [[ 1. حالة السحب (Grab) ]]
                    local target = mouse.Target
                    if target and target:IsA("BasePart") and not target.Anchored then
                        -- التأكد أنها ليست جزء من لاعب
                        local model = target:FindFirstAncestorOfClass("Model")
                        if model and model:FindFirstChildOfClass("Humanoid") then return end

                        heldPart = target
                        heldPart.Massless = true

                        -- زرع محركات الجاذبية
                        bp = Instance.new("BodyPosition")
                        bp.Name = "Cryptic_Gravity_BP"
                        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bp.P = 50000
                        bp.D = 500
                        bp.Parent = heldPart

                        bg = Instance.new("BodyGyro")
                        bg.Name = "Cryptic_Gravity_BG"
                        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        bg.P = 3000
                        bg.Parent = heldPart

                    else
                        SendRobloxNotification("Cryptic Hub", "⚠️ أشر على بلوكة غير مثبتة (Unanchored) لسحبها!")
                    end
                else
                    -- [[ 2. حالة الإطلاق (Shoot) ]]
                    local shootDir = mouse.UnitRay.Direction
                    
                    -- إزالة المحركات قبل الإطلاق
                    if bp then bp:Destroy() bp = nil end
                    if bg then bg:Destroy() bg = nil end
                    
                    -- إعطاء البلوكة سرعة صاروخية في اتجاه المؤشر
                    heldPart.AssemblyLinearVelocity = shootDir * 800 -- سرعة مرعبة للإطلاق
                    
                    -- إرجاع الوزن الطبيعي بعد ثانية عشان تدمج الهدف
                    local shotPart = heldPart
                    heldPart = nil
                    
                    task.delay(0.5, function()
                        pcall(function() shotPart.Massless = false end)
                    end)
                end
            end)

            -- عند إلغاء تجهيز الأداة من اليد (Unequip) تسقط البلوكة
            tool.Unequipped:Connect(function()
                releasePart()
            end)

            -- تحديث مكان البلوكة لتكون أمام الكاميرا دائماً
            updateConnection = RunService.RenderStepped:Connect(function()
                if heldPart and bp and bg then
                    -- جعل البلوكة تطفو أمام الكاميرا بمسافة 12 متر
                    local targetPos = cam.CFrame.Position + (cam.CFrame.LookVector * 12)
                    bp.Position = targetPos
                    -- جعل البلوكة تدور بشكل سينمائي وهي معلقة
                    bg.CFrame = cam.CFrame * CFrame.Angles(math.rad(tick() * 100), math.rad(tick() * 50), 0)
                end
            end)

        else
            -- إيقاف الأداة وتنظيف كل شيء
            if tool then tool:Destroy() end
            releasePart()
            if updateConnection then updateConnection:Disconnect() end
            SendRobloxNotification("Cryptic Hub", "❌ تم إزالة مسدس الجاذبية.")
        end
    end)
end
