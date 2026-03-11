-- [[ Cryptic Hub - Ultimate Walk Fling + Anti-Fling ]]
-- المطور: مدمج (Walk Fling + Anti-Wall + Anti-Fling)

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local flingConnection = nil
    local bav = nil -- للتحكم في الدوران
    local bv = nil  -- للتحكم في الثبات ومنع الارتداد من الجدران

    -- دالة الإشعارات المزدوجة
    local function Notify(arText, enText)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 3
            })
        end)
    end

    Tab:AddToggle("Walk Fling / الدفع بالمشي", function(state)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if state then
            if not hrp or not hum then return end
            
            -- إظهار الإشعار
            Notify("🌪️ تم تفعيل الدفع بالمشي + مضاد التطيير", "🌪️ Walk Fling + Anti-Fling Activated")
            
            -- 1. أداة الدوران (تطير اللاعبين بقوة 20000)
            bav = Instance.new("BodyAngularVelocity")
            bav.Name = "CrypticFlingBAV"
            bav.AngularVelocity = Vector3.new(0, 20000, 0) 
            bav.MaxTorque = Vector3.new(0, math.huge, 0)
            bav.P = math.huge
            bav.Parent = hrp

            -- 2. أداة الثبات (تمنع ارتدادك من الجدران)
            bv = Instance.new("BodyVelocity")
            bv.Name = "CrypticFlingBV"
            bv.MaxForce = Vector3.new(math.huge, 0, math.huge) 
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp

            -- 3. حلقة التحكم المستمر (تشمل كل شيء)
            -- نستخدم Stepped لأنه الأفضل للتعامل مع الفيزياء والتصادم قبل رندرة اللعبة
            flingConnection = RunService.Stepped:Connect(function()
                if char and hrp and hum then
                    
                    -- [A] تحديث سرعتك لتتطابق مع حركتك الحقيقية (يمنع الحيط من دفعك)
                    bv.Velocity = hum.MoveDirection * hum.WalkSpeed
                    
                    -- [B] حماية من السقف (قفل السرعة العمودية لمنع الطيران الفوق والموت)
                    if hrp.Velocity.Y > 40 or hrp.Velocity.Y < -40 then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, math.clamp(hrp.Velocity.Y, -40, 40), hrp.Velocity.Z)
                    end

                    -- [C] ميزة Anti-Fling (إلغاء التصادم مع اللاعبين الآخرين لتخترقهم)
                    for _, otherPlayer in pairs(Players:GetPlayers()) do
                        if otherPlayer ~= LocalPlayer and otherPlayer.Character then
                            for _, part in pairs(otherPlayer.Character:GetChildren()) do
                                if part:IsA("BasePart") and part.CanCollide then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                    
                end
            end)
        else
            -- حالة الإيقاف: مسح الأدوات وإرجاع اللاعب لطبيعته
            if flingConnection then flingConnection:Disconnect() flingConnection = nil end
            if bav then bav:Destroy() bav = nil end
            if bv then bv:Destroy() bv = nil end
            
            if hrp then
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
end
