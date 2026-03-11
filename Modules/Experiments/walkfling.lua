-- [[ Cryptic Hub - Flawless Walk Fling + Anti-Fling Module ]]
return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local flingLoop = nil
    local bav = nil -- BodyAngularVelocity

    Tab:AddToggle("Walk Fling / الدفع بالمشي", function(state)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if state then
            if not hrp or not hum then return end
            
            -- 1. استعمال BodyAngularVelocity لدوران سلس ومستقر (ما غيطيحكش تحت الأرض)
            bav = Instance.new("BodyAngularVelocity")
            bav.Name = "CrypticFling"
            bav.AngularVelocity = Vector3.new(0, 50000, 0)
            bav.MaxTorque = Vector3.new(0, math.huge, 0)
            bav.P = math.huge
            bav.Parent = hrp

            -- 2. حلقة المراقبة (Anti-Fling + Anti-Trip)
            flingLoop = RunService.Stepped:Connect(function()
                if char and hrp and hum then
                    -- منع اللاعب من الجلوس أو السقوط أثناء التفعيل
                    hum.Sit = false
                    if hum:GetState() == Enum.HumanoidStateType.FallingDown or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end

                    -- [[ نظام Anti-Fling الخاص بك ]]
                    -- إلا محرك اللعبة حاول يطيرك للسما أو يلوحك بعيد، هاد الكود كيحبسك ويرجعك لسرعتك الطبيعية
                    if hrp.Velocity.Magnitude > 50 then
                        -- نحبسو السرعة فـ 50 باش تبقى شاد فالأرض ومتحكم فالمشي ديالك
                        hrp.Velocity = hrp.Velocity.Unit * 50
                    end
                end
            end)
        else
            -- حالة الإيقاف: مسح كل شيء وإرجاع اللاعب لطبيعته
            if flingLoop then
                flingLoop:Disconnect()
                flingLoop = nil
            end
            if bav then
                bav:Destroy()
                bav = nil
            end
            
            if hrp then
                -- تصفير أي سرعة متبقية باش توقف فبلاصتك
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
end
