-- [[ Cryptic Hub - رقص أمام الهدف (Target Jerk) ]]
-- المطور: يامي | الوصف: تتبع مستمر، وقوف أمام الوجه 180 درجة، أنميشن مدمج ولا يتوقف عند الموت

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    
    local isJerkingAtTarget = false
    local loopConnection = nil
    local track = nil
    local lastMyChar = nil

    -- 🔴 تنبيه: استخدمنا المتغير _G.CrypticTarget كمثال لاسم اللاعب المستهدف
    -- إذا كان لديك مربع نص (TextBox) لتحديد الهدف، اجعله يحفظ الاسم في هذا المتغير!
    _G.CrypticTarget = "" 

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3}) end)
    end

    -- دالة ذكية للبحث عن اللاعب المستهدف (تقبل كتابة جزء من اسمه)
    local function GetTargetPlayer()
        local targetName = _G.CrypticTarget 
        if targetName and targetName ~= "" then
            for _, p in ipairs(Players:GetPlayers()) do
                if string.find(string.lower(p.Name), string.lower(targetName)) or string.find(string.lower(p.DisplayName), string.lower(targetName)) then
                    return p
                end
            end
        end
        return nil
    end

    local function StopAction()
        isJerkingAtTarget = false
        if loopConnection then loopConnection:Disconnect() loopConnection = nil end
        if track then track:Stop() track = nil end
        
        -- إرجاع التصادم والفيزياء للطبيعة
        if lp.Character then
            for _, part in pairs(lp.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
            local root = lp.Character:FindFirstChild("HumanoidRootPart")
            if root then root.Velocity = Vector3.new(0,0,0) end
        end
    end

    -- ==========================================
    -- واجهة المستخدم (تحديد الهدف + التفعيل)
    -- ==========================================
    Tab:AddInput("اسم الهدف / Target Name", "اكتب اسم اللاعب هنا...", function(text)
        _G.CrypticTarget = text
    end)

    Tab:AddToggle("رقص أمام الهدف / Jerk at Target", function(state)
        isJerkingAtTarget = state
        
        if state then
            local targetPlayer = GetTargetPlayer()
            if not targetPlayer then
                Notify("خطأ ⚠️", "الرجاء كتابة اسم لاعب موجود في السيرفر!")
                StopAction()
                return -- يفضل أن يكون الزر مطفأ إذا لم يجد اللاعب
            end

            Notify("🎯 استهداف", "تم قفل الهدف على: " .. targetPlayer.DisplayName)

            loopConnection = RunService.Stepped:Connect(function()
                if not isJerkingAtTarget then return end
                
                targetPlayer = GetTargetPlayer() -- تحديث مستمر
                if not targetPlayer then return end

                local myChar = lp.Character
                local targetChar = targetPlayer.Character

                if myChar and targetChar then
                    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    local myHum = myChar:FindFirstChildOfClass("Humanoid")
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

                    -- التحقق من أن الاثنين أحياء وموجودين في الماب
                    if myRoot and myHum and myHum.Health > 0 and targetRoot and targetHum and targetHum.Health > 0 then
                        
                        -- 1. إيقاف التصادم لشخصيتك عشان ما تدف الهدف ويخرب مكانه (Noclip)
                        for _, part in pairs(myChar:GetChildren()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end

                        -- 2. التحقق من تحميل الأنميشن (يتحمل مرة واحدة لكل حياة جديدة)
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
                            track.Looped = true -- تكرار تلقائي
                            track:Play()
                            track:AdjustSpeed(isR15 and 0.7 or 0.65)
                        elseif not track.IsPlaying then
                            track:Play()
                        end

                        -- 3. هندسة الموقع:
                        -- CFrame.new(0, 0, -2.5) = يضعك أمام وجه اللاعب بمسافة 2.5 خطوة
                        -- CFrame.Angles(0, math.pi, 0) = يلف شخصيتك 180 درجة لتنظر في عينه مباشرة!
                        myRoot.Velocity = Vector3.new(0, 0, 0)
                        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -2.5) * CFrame.Angles(0, math.pi, 0)
                        
                    else
                        -- لو أنت أو الهدف متّم، نوقف الأنميشن مؤقتاً لين ترسبنون
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
