-- [[ Cryptic Hub - المشي على الجدران (Wall Walk/Spider) ]]
-- المطور: Cryptic | التحديث: إضافة أنيميشن المشي الطبيعي وتقوية الالتصاق لمنع الطيران

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    local isWallWalk = false
    local connection = nil
    local bg = nil
    local bv = nil
    local walkTrack = nil -- متغير لحفظ أنيميشن المشي

    -- دالة إرسال الإشعارات على الشاشة
    local function SendScreenNotify(title, text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title, Text = text, Duration = 3
            })
        end)
    end

    Tab:AddToggle("المشي على الجدران (Spider)", function(active)
        isWallWalk = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if active then
            if root and hum then
                SendScreenNotify("Cryptic Hub", "🕷️ تم التفعيل! أرجل شخصيتك ستتحرك بشكل طبيعي على الجدران.")
                
                hum.PlatformStand = true
                
                -- إعدادات الدوران والحركة
                bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.P = 3000
                bg.Parent = root
                
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.zero
                bv.Parent = root
                
                -- [[ الحل السحري: جلب أنيميشن المشي الخاص بشخصيتك ]]
                pcall(function()
                    local animate = char:FindFirstChild("Animate")
                    if animate then
                        local animObj = nil
                        -- البحث عن حركة الركض أو المشي
                        if animate:FindFirstChild("run") and animate.run:FindFirstChild("RunAnim") then
                            animObj = animate.run.RunAnim
                        elseif animate:FindFirstChild("walk") and animate.walk:FindFirstChild("WalkAnim") then
                            animObj = animate.walk.WalkAnim
                        end
                        -- تحميل الحركة لدمجها مع السكربت
                        if animObj then
                            walkTrack = hum:LoadAnimation(animObj)
                        end
                    end
                end)
                
                connection = RunService.RenderStepped:Connect(function()
                    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
                    local currentRoot = lp.Character.HumanoidRootPart
                    local currentHum = lp.Character:FindFirstChild("Humanoid")
                    
                    local origin = currentRoot.Position
                    
                    -- تقليل المسافة إلى 2.5 عشان يلصق فقط إذا كان يلامس الجدار (منع الطيران)
                    local directions = {
                        currentRoot.CFrame.UpVector * -2.5,
                        currentRoot.CFrame.UpVector * 2.5,
                        currentRoot.CFrame.LookVector * 2.5,
                        currentRoot.CFrame.RightVector * 2.5,
                        currentRoot.CFrame.RightVector * -2.5
                    }
                    
                    local bestNormal = Vector3.new(0, 1, 0)
                    local bestDist = math.huge
                    local hitFound = false
                    
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {lp.Character}
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    
                    for _, dir in ipairs(directions) do
                        local res = workspace:Raycast(origin, dir, rayParams)
                        if res and res.Distance < bestDist then
                            bestDist = res.Distance
                            bestNormal = res.Normal
                            hitFound = true
                        end
                    end
                    
                    if hitFound then
                        -- تعديل وقفة اللاعب ليكون موازي للجدار
                        local lookDir = workspace.CurrentCamera.CFrame.LookVector
                        local projLook = lookDir - (lookDir:Dot(bestNormal) * bestNormal)
                        
                        if projLook.Magnitude > 0 then
                            local up = bestNormal
                            local forward = projLook.Unit
                            local right = forward:Cross(up).Unit
                            bg.CFrame = CFrame.fromMatrix(currentRoot.Position, right, up, -forward)
                        end
                        
                        -- نظام الحركة (W, A, S, D)
                        local moveDir = currentHum.MoveDirection
                        local moveVelocity = Vector3.zero
                        
                        if moveDir.Magnitude > 0 then
                            local projMove = moveDir - (moveDir:Dot(bestNormal) * bestNormal)
                            if projMove.Magnitude > 0 then
                                moveVelocity = projMove.Unit * currentHum.WalkSpeed
                            end
                            
                            -- [[ تشغيل حركة الأرجل (أنيميشن) إذا كنت تتحرك ]]
                            if walkTrack and not walkTrack.IsPlaying then
                                walkTrack:Play()
                            end
                        else
                            -- [[ إيقاف حركة الأرجل إذا وقفت ]]
                            if walkTrack and walkTrack.IsPlaying then
                                walkTrack:Stop()
                            end
                        end
                        
                        -- قوة جذب قوية جداً (-15) عشان تلصق بالجدار ولا تطفو
                        bv.Velocity = moveVelocity + (bestNormal * -15)
                    else
                        -- إذا كنت في الهواء ولا يوجد جدار (سقوط طبيعي)
                        if walkTrack and walkTrack.IsPlaying then walkTrack:Stop() end
                        bv.Velocity = Vector3.new(0, -50, 0)
                        bg.CFrame = CFrame.new(currentRoot.Position, currentRoot.Position + workspace.CurrentCamera.CFrame.LookVector)
                    end
                end)
            end
        else
            SendScreenNotify("Cryptic Hub", "🛑 تم إيقاف المشي على الجدران.")
            -- تنظيف كل شيء عند إيقاف الزر
            if connection then connection:Disconnect() connection = nil end
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
            if hum then hum.PlatformStand = false end
            if walkTrack then walkTrack:Stop() end
        end
    end)
end
