-- [[ Cryptic Hub - رقص أمام الهدف السريع (Fast Target Jerk V2) ]]
-- المطور: يامي | الوصف: أنميشن سريع مدمج (بدون أداة)، تتبع Face-to-Face، وتحديد من القائمة

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    
    local isJerkingAtTarget = false
    local loopConnection = nil
    local track = nil
    local lastMyChar = nil

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3}) end)
    end

    local function StopAction()
        isJerkingAtTarget = false
        if loopConnection then loopConnection:Disconnect() loopConnection = nil end
        if track then track:Stop() track = nil end
        
        -- إرجاع التصادم للطبيعة
        if lp.Character then
            for _, part in pairs(lp.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
            local root = lp.Character:FindFirstChild("HumanoidRootPart")
            if root then root.Velocity = Vector3.new(0,0,0) end
        end
    end

    Tab:AddToggle("رقص أمام الهدف / Jerk at Target", function(state)
        isJerkingAtTarget = state
        
        if state then
            -- 🔴 الاعتماد على تحديد اللاعب من قائمة (Cryptic Hub) اللي برمجتها أنت
            local targetPlayer = _G.ArwaTarget
            
            if not targetPlayer then
                Notify("خطأ ⚠️", "الرجاء تحديد لاعب من القائمة في الأعلى أولاً!")
                StopAction()
                return
            end

            Notify("🎯 استهداف", "جاري الرقص أمام: " .. targetPlayer.DisplayName)

            loopConnection = RunService.Stepped:Connect(function()
                if not isJerkingAtTarget then return end
                
                -- تحديث الهدف باستمرار لضمان عدم خروجه
                targetPlayer = _G.ArwaTarget
                if not targetPlayer then 
                    StopAction()
                    Notify("⚠️ تنبيه", "اللاعب الهدف غير موجود أو غادر!")
                    return 
                end

                local myChar = lp.Character
                local targetChar = targetPlayer.Character

                if myChar and targetChar then
                    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    local myHum = myChar:FindFirstChildOfClass("Humanoid")
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

                    if myRoot and myHum and myHum.Health > 0 and targetRoot and targetHum and targetHum.Health > 0 then
                        
                        -- 1. Noclip لشخصيتك عشان ما تدف الهدف
                        for _, part in pairs(myChar:GetChildren()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end

                        -- 2. التحميل الذكي للأنميشن (بدون Tool) كأنه أمر مباشر!
                        if lastMyChar ~= myChar then
                            lastMyChar = myChar
                            if track then track:Stop() track = nil end
                        end

                        if not track then
                            local isR15 = myHum.RigType == Enum.HumanoidRigType.R15
                            local anim = Instance.new("Animation")
                            anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
                            track = myHum:LoadAnimation(anim)
                            track.Priority = Enum.AnimationPriority.Action
                            track.Looped = true
                        end

                        -- 🔴 تسريع الأنميشن كما طلبت (نفس الكود اللي أرسلته)
                        if not track.IsPlaying then
                            track:Play()
                            local isR15 = myHum.RigType == Enum.HumanoidRigType.R15
                            track:AdjustSpeed(isR15 and 0.7 or 0.65)
                        end
                        -- وضع الحركة في الجزء السريع من الأنميشن
                        track.TimePosition = 0.6 

                        -- 3. هندسة الموقع: أمام الوجه بـ 2.5 خطوة والنظر في العين (180 درجة)
                        myRoot.Velocity = Vector3.new(0, 0, 0)
                        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -2.5) * CFrame.Angles(0, math.pi, 0)
                        
                    else
                        -- لو أحد مات، نوقف الأنميشن مؤقتاً
                        if track then track:Stop() track = nil end
                    end
                end
            end)
        else
            StopAction()
            Notify("🛑 توقف", "تم إيقاف التتبع والرقص.")
        end
    end)
    
    Tab:AddLine()
end
