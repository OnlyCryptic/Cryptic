-- [[ Cryptic Hub - رقص أمام الهدف (Target Jerk V4 - Anti-Vibrate) ]]
-- المطور: يامي | الوصف: تتبع وجه لوجه، حركة يد سريعة، تنظيف احترافي للاهتزاز، نصوص مزدوجة

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    
    local isJerkingAtTarget = false
    local loopConnection = nil
    local currentTrack = nil -- المتغير صار هنا عشان نمسحه فوراً عند الإيقاف

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3}) end)
    end

    local function StopAction()
        isJerkingAtTarget = false
        if loopConnection then loopConnection:Disconnect() loopConnection = nil end
        
        -- التدمير الفوري للأنميشن
        if currentTrack then 
            currentTrack:Stop() 
            currentTrack:Destroy() 
            currentTrack = nil 
        end
        
        if lp.Character then
            -- إرجاع التصادم والفيزياء للطبيعة
            for _, part in pairs(lp.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
            
            local root = lp.Character:FindFirstChild("HumanoidRootPart")
            if root then 
                root.Velocity = Vector3.new(0,0,0) 
                root.RotVelocity = Vector3.new(0,0,0) 
            end
            
            -- التنظيف العميق عبر الـ Animator لمنع الاهتزاز والمشي الغريب
            local hum = lp.Character:FindFirstChildOfClass("Humanoid")
            local animator = hum and hum:FindFirstChildOfClass("Animator")
            
            if animator then
                for _, animTrack in pairs(animator:GetPlayingAnimationTracks()) do
                    if animTrack.Animation.AnimationId == "rbxassetid://698251653" or animTrack.Animation.AnimationId == "rbxassetid://72042024" then
                        animTrack:Stop()
                        animTrack:Destroy()
                    end
                end
            end
        end
    end

    Tab:AddToggle("تخليج أمام الهدف / Jerk at Target", function(state)
        isJerkingAtTarget = state
        
        if state then
            local targetPlayer = _G.ArwaTarget
            if not targetPlayer then
                Notify("خطأ ⚠️ / Error", "الرجاء تحديد لاعب من القائمة أولاً!\nPlease select a player first!")
                StopAction()
                return
            end

            Notify("🎯 استهداف / Locked", "جاري الرقص أمام / Jerking at: " .. targetPlayer.DisplayName)

            -- 🔴 1. حلقة الأنميشن السريعة
            task.spawn(function()
                local lastMyChar = nil
                
                while isJerkingAtTarget do
                    local myChar = lp.Character
                    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                    local animator = myHum and myHum:FindFirstChildOfClass("Animator")
                    
                    if myHum and animator and myHum.Health > 0 then
                        local isR15 = myHum.RigType == Enum.HumanoidRigType.R15
                        
                        -- إعادة التحميل لو ترسبن اللاعب
                        if lastMyChar ~= myChar then
                            lastMyChar = myChar
                            if currentTrack then currentTrack:Stop() currentTrack:Destroy() currentTrack = nil end
                        end

                        -- الاعتماد على Animator بدلاً من Humanoid لمنع تسريب الذاكرة والاهتزاز
                        if not currentTrack then
                            local anim = Instance.new("Animation")
                            anim.AnimationId = isR15 and "rbxassetid://698251653" or "rbxassetid://72042024"
                            currentTrack = animator:LoadAnimation(anim)
                            currentTrack.Priority = Enum.AnimationPriority.Action
                        end

                        currentTrack:Play()
                        currentTrack:AdjustSpeed(isR15 and 0.7 or 0.65)
                        currentTrack.TimePosition = 0.6
                        
                        local targetTime = isR15 and 0.7 or 0.65
                        
                        while isJerkingAtTarget and currentTrack and currentTrack.TimePosition < targetTime do 
                            task.wait() 
                        end
                        
                        if currentTrack then currentTrack:Stop() end
                    else
                        task.wait(0.5) 
                    end
                end
            end)

            -- 🔴 2. حلقة التتبع والانتقال
            loopConnection = RunService.Stepped:Connect(function()
                if not isJerkingAtTarget then return end
                
                targetPlayer = _G.ArwaTarget
                if not targetPlayer then 
                    StopAction()
                    Notify("⚠️ تنبيه / Alert", "اللاعب الهدف غير موجود أو غادر!\nTarget player left!")
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
                        
                        for _, part in pairs(myChar:GetChildren()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end

                        myRoot.Velocity = Vector3.new(0, 0, 0)
                        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -2.5) * CFrame.Angles(0, math.pi, 0)
                    end
                end
            end)
        else
            StopAction()
            Notify("🛑 توقف / Stopped", "تم إيقاف التتبع والرقص.\nTracking stopped.")
        end
    end)
    
    Tab:AddLine()
end
