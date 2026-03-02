-- [[ Cryptic Hub - المشي على الجدران (Wall Walk/Spider) ]]
-- المطور: Cryptic | التحديث: يمشي على الأسقف والجدران المائلة مثل سبايدرمان

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    local isWallWalk = false
    local connection = nil
    local bg = nil
    local bv = nil

    -- دالة إرسال الإشعارات على الشاشة
    local function SendScreenNotify(title, text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 3
            })
        end)
    end

    Tab:AddToggle("المشي على الجدران (Spider)", function(active)
        isWallWalk = active
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if active then
            SendScreenNotify("Cryptic Hub", "🕷️ تم تفعيل المشي على الجدران! الصق بأي سقف أو جدار.")
            
            if root and hum then
                -- إلغاء فيزياء السقوط الطبيعية
                hum.PlatformStand = true
                
                -- إنشاء متحكم الدوران (لتوجيهك حسب الجدار)
                bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.P = 3000
                bg.Parent = root
                
                -- إنشاء متحكم الحركة (للمشي ولصقك بالجدار)
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.zero
                bv.Parent = root
                
                connection = RunService.RenderStepped:Connect(function()
                    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
                    local currentRoot = lp.Character.HumanoidRootPart
                    local currentHum = lp.Character:FindFirstChild("Humanoid")
                    
                    -- إطلاق أشعة (Raycast) في كل الاتجاهات للبحث عن أقرب جدار/سقف
                    local origin = currentRoot.Position
                    local directions = {
                        currentRoot.CFrame.UpVector * -5,    -- أسفل
                        currentRoot.CFrame.UpVector * 5,     -- أعلى (سقف)
                        currentRoot.CFrame.LookVector * 5,   -- أمام
                        currentRoot.CFrame.RightVector * 5,  -- يمين
                        currentRoot.CFrame.RightVector * -5  -- يسار
                    }
                    
                    local bestNormal = Vector3.new(0, 1, 0)
                    local bestDist = math.huge
                    local hitFound = false
                    
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {lp.Character}
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    
                    -- تحديد أقرب سطح لك
                    for _, dir in ipairs(directions) do
                        local res = workspace:Raycast(origin, dir, rayParams)
                        if res and res.Distance < bestDist then
                            bestDist = res.Distance
                            bestNormal = res.Normal
                            hitFound = true
                        end
                    end
                    
                    if hitFound then
                        -- 1. تعديل دوران الشخصية لتوازي الجدار أو السقف تماماً
                        local lookDir = workspace.CurrentCamera.CFrame.LookVector
                        local projLook = lookDir - (lookDir:Dot(bestNormal) * bestNormal)
                        
                        if projLook.Magnitude > 0 then
                            local up = bestNormal
                            local forward = projLook.Unit
                            local right = forward:Cross(up).Unit
                            bg.CFrame = CFrame.fromMatrix(currentRoot.Position, right, up, -forward)
                        end
                        
                        -- 2. تحريك الشخصية على الجدار بناءً على أزرار المشي (W,A,S,D)
                        local moveDir = currentHum.MoveDirection
                        local moveVelocity = Vector3.zero
                        
                        if moveDir.Magnitude > 0 then
                            local projMove = moveDir - (moveDir:Dot(bestNormal) * bestNormal)
                            if projMove.Magnitude > 0 then
                                moveVelocity = projMove.Unit * currentHum.WalkSpeed
                            end
                        end
                        
                        -- قوة دفع خفيفة للصق الشخصية بالجدار (-5) لمنع السقوط
                        bv.Velocity = moveVelocity + (bestNormal * -5)
                    else
                        -- إذا لم يجد جداراً، يسقط بشكل طبيعي
                        bv.Velocity = Vector3.new(0, -50, 0)
                        bg.CFrame = CFrame.new(currentRoot.Position, currentRoot.Position + workspace.CurrentCamera.CFrame.LookVector)
                    end
                end)
            end
        else
            SendScreenNotify("Cryptic Hub", "🛑 تم إيقاف المشي على الجدران.")
            -- تنظيف الكود عند الإيقاف وإرجاع الجاذبية
            if connection then connection:Disconnect() connection = nil end
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
            if hum then hum.PlatformStand = false end
        end
    end)
end
