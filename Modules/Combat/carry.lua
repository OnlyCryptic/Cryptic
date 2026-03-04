-- [[ Cryptic Hub - المصعد الفيزيائي المطور ]]  
-- المطور: يامي (Yami) | يعتمد على ملف الاستهداف target_select.lua
  
return function(Tab, UI)  
    local runService = game:GetService("RunService")  
    local players = game:GetService("Players")  
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer  
      
    local isCarrying = false  
    local liftHeight = 0  
    local liftSpeed = 0.03 
    
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 4,
            })
        end)
    end
  
    -- [[ زر التفعيل للرفع الفيزيائي مع فحص التصادم ]]  
    Tab:AddToggle("حمل اللاعب / Carry Player", function(active)  
        isCarrying = active  
        local char = lp.Character  
        local root = char and char:FindFirstChild("HumanoidRootPart")
          
        if active then  
            -- قراءة الهدف من المتغير العام الخاص بملف البحث
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then  
                isCarrying = false  
                SendRobloxNotification("Cryptic Hub", "⚠️ حدد لاعباً أولاً من مربع البحث أعلى القائمة!")  
                return  
            end  
            
            -- فحص نظام التصادم في الماب (Collision Check)
            local targetChar = _G.ArwaTarget.Character
            local myTorso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or root
            local targetTorso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("HumanoidRootPart")
            
            if myTorso and targetTorso then
                local success, canCollide = pcall(function()
                    return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, targetTorso.CollisionGroup)
                end)
                
                if success and not canCollide then
                    isCarrying = false
                    SendRobloxNotification("Cryptic Hub", "🚫 هذا الماب يلغي تلامس اللاعبين (No-Collide)، الخدعة لن تعمل هنا!")
                    return 
                end
            end
              
            if char then  
                local hum = char:FindFirstChildOfClass("Humanoid")  
                if hum then hum.PlatformStand = true end  
            end  
              
            liftHeight = -7 
            SendRobloxNotification("Cryptic Hub", "🚀 شخصيتك تخرج الآن من تحت الأرض...")  
        else  
            -- التنظيف الفيزيائي عند الإيقاف
            if char then  
                local hum = char:FindFirstChildOfClass("Humanoid")  
                if hum then hum.PlatformStand = false end  
                
                if root then
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                end

                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Massless = false 
                    end
                end
            end  
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف الرفع الفيزيائي وتنظيف الحركة")  
        end  
    end)  
  
    -- [[ المحرك الفيزيائي ]]  
    runService.Heartbeat:Connect(function()  
        if not isCarrying or not _G.ArwaTarget then return end  
          
        local char = lp.Character  
        local root = char and char:FindFirstChild("HumanoidRootPart")  
        local targetChar = _G.ArwaTarget.Character  
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")  
  
        if root and targetRoot then  
            for _, part in pairs(char:GetDescendants()) do  
                if part:IsA("BasePart") then  
                    if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then  
                        part.CanCollide = true  
                    else  
                        part.CanCollide = false  
                    end  
                    part.Massless = true  
                end  
            end  
  
            liftHeight = liftHeight + liftSpeed  
            local tPos = targetRoot.Position  
              
            root.CFrame = CFrame.new(tPos.X, tPos.Y + liftHeight, tPos.Z) * CFrame.Angles(math.rad(90), 0, 0)  
            root.Velocity = Vector3.new(0, 15, 0)  
            root.RotVelocity = Vector3.new(0, 0, 0)  
        end  
    end)  
end
