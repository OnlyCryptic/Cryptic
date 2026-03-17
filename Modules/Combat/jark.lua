-- [[ Cryptic Hub - رقص أمام الهدف (Target Jerk V3) ]]
-- المطور: يامي | الوصف: تتبع وجه لوجه + حركة اليد السريعة (نفس الأداة بالضبط)

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    
    local isJerkingAtTarget = false
    local loopConnection = nil

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3}) end)
    end

    local function StopAction()
        isJerkingAtTarget = false
        if loopConnection then loopConnection:Disconnect() loopConnection = nil end
        
        -- إرجاع التصادم للطبيعة وتنظيف الأنميشن
        if lp.Character then
            for _, part in pairs(lp.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
            local root = lp.Character:FindFirstChild("HumanoidRootPart")
            if root then root.Velocity = Vector3.new(0,0,0) end
            
            local hum = lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, animTrack in pairs(hum:GetPlayingAnimationTracks()) do
                    if animTrack.Animation.AnimationId == "rbxassetid://698251653" or animTrack.Animation.AnimationId == "rbxassetid://72042024" then
                        animTrack:Stop()
                    end
                end
            end
        end
    end

    Tab:AddToggle("رقص أمام الهدف / Jerk at Target", function(state)
        isJerkingAtTarget = state
        
        if state then
            local targetPlayer = _G.ArwaTarget
            if not targetPlayer then
                Notify("خطأ ⚠️", "الرجاء تحديد لاعب من القائمة في الأعلى أولاً!")
                StopAction()
                return
            end

            Notify("🎯 استهداف", "جاري الرقص أمام: " .. targetPlayer.DisplayName)

            -- 🔴 1. حلقة الأنميشن السريعة (نطابق حركة الأداة 100%)
            task.spawn(function()
                local lastMyChar = nil
                local track = nil
                
                while isJerkingAtTarget do
                    local myChar = lp.Character
                    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                    
                    if myHum and myHum.Health > 0 then
                        local isR15 = myHum.RigType == Enum.HumanoidRigType.R15
                        
                        -- تحميل الأنميشن مرة واحدة فقط لكل حياة
                        if lastMyChar ~= myChar then
                            lastMyChar = myChar
                            if track then track:Stop() track:Destroy() track = nil end
                        end

                        if not track then
                            local anim = Instance.new("Animation")
                            anim.AnimationId = isR15 and "rbxassetid://698251653" or "rbxassetid://72042024"
                            track = myHum:LoadAnimation(anim)
                            track.Priority = Enum.AnimationPriority.Action
                        end

                        -- اللوب السريع المجنون (نفس الأداة بالضبط)
                        track:Play()
                        track:AdjustSpeed(isR15 and 0.7 or 0.65)
                        track.TimePosition = 0.6
                        
                        local targetTime = isR15 and 0.7 or 0.65
                        
                        while isJerkingAtTarget and track and track.TimePosition < targetTime do 
                            task.wait() 
                        end
                        
                        if track then track:Stop() end
                    else
                        task.wait(0.5) -- انتظار حتى يرسبن اللاعب
                    end
                end
                
                if track then track:Stop() track:Destroy() end
            end)

            -- 🔴 2. حلقة التتبع والانتقال (CFrame Face-to-Face)
            loopConnection = RunService.Stepped:Connect(function()
                if not isJerkingAtTarget then return end
                
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
                        
                        -- Noclip لشخصيتك عشان ما تدف الهدف
                        for _, part in pairs(myChar:GetChildren()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end

                        -- هندسة الموقع: أمام الوجه بـ 2.5 خطوة والنظر في العين (180 درجة)
                        myRoot.Velocity = Vector3.new(0, 0, 0)
                        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -2.5) * CFrame.Angles(0, math.pi, 0)
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
