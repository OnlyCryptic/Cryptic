-- [[ Cryptic Hub - المصعد الفيزيائي المطور (Sleeping Elevator) ]]  
-- المطور: يامي (Yami) | الميزات: وضعية النوم، خروج من تحت الأرض، Anti-Fling، Noclip، تنظيف فيزيائي  
  
return function(Tab, UI)  
    local runService = game:GetService("RunService")  
    local players = game:GetService("Players")  
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
  
    -- [[ 1. نظام البحث الذكي عن اللاعبين ]]  
    local InputField = Tab:AddInput("🔍 البحث عن لاعب", "اكتب اليوزر وأغلق الكيبورد...", function() end)  
  
    InputField.TextBox.FocusLost:Connect(function()  
        local txt = InputField.TextBox.Text  
        if txt == "" then _G.CrypticTarget = nil return end  
        
        local bestMatch = nil  
        local search = txt:lower()  
  
        for _, p in pairs(players:GetPlayers()) do  
            if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then  
                bestMatch = p  
                break   
            end  
        end  
  
        if bestMatch then  
            _G.CrypticTarget = bestMatch  
            InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")  
            SendRobloxNotification("Cryptic Hub", "🎯 تم قفل الهدف: " .. bestMatch.DisplayName)  
        else  
            _G.CrypticTarget = nil  
            SendRobloxNotification("Cryptic Hub", "❌ لم يتم العثور على اللاعب")  
        end  
    end)  
  
    -- [[ 2. زر التفعيل للرفع الفيزيائي ]]  
    Tab:AddToggle("حمل لاعب / PFlying", function(active)  
        isCarrying = active  
        local char = lp.Character  
        local root = char and char:FindFirstChild("HumanoidRootPart")
          
        if active then  
            if not _G.CrypticTarget or not _G.CrypticTarget.Character then  
                isCarrying = false  
                SendRobloxNotification("Cryptic Hub", "⚠️ حدد لاعباً أولاً من مربع البحث!")  
                return  
            end  
              
            if char then  
                local hum = char:FindFirstChildOfClass("Humanoid")  
                if hum then hum.PlatformStand = true end  
            end  
              
            liftHeight = -7 
            SendRobloxNotification("Cryptic Hub", "🚀 شخصيتك تخرج الآن من تحت الأرض...")  
        else  
            -- [[ التعديل الجذري هنا: التنظيف الفيزيائي عند الإيقاف ]]
            if char then  
                local hum = char:FindFirstChildOfClass("Humanoid")  
                if hum then hum.PlatformStand = false end  
                
                if root then
                    -- تصفير أي قوة دفع متراكمة لمنع الطيران عند مسك أداة
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                end

                -- إرجاع الأوزان الطبيعية للأطراف
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Massless = false 
                    end
                end
            end  
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف الرفع الفيزيائي وتنظيف الحركة")  
        end  
    end)  
  
    -- [[ 3. المحرك الفيزيائي ]]  
    runService.Heartbeat:Connect(function()  
        if not isCarrying or not _G.CrypticTarget then return end  
          
        local char = lp.Character  
        local root = char and char:FindFirstChild("HumanoidRootPart")  
        local targetChar = _G.CrypticTarget.Character  
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
