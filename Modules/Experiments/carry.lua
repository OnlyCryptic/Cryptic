-- [[ Cryptic Hub - المصعد الفيزيائي المطور (Sleeping Elevator) ]]  
-- المطور: يامي (Yami) | الميزات: وضعية النوم، خروج من تحت الأرض، Anti-Fling، Noclip  
  
return function(Tab, UI)  
    local runService = game:GetService("RunService")  
    local players = game:GetService("Players")  
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer  
      
    local isCarrying = false  
    local liftHeight = 0  
    local liftSpeed = 0.05 -- سرعة الصعود البطيئة جداً من تحت الأرض  
    local startY = 0 
    
    -- دالة إشعارات روبلوكس الأصلية لتجنب أي تعليق
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
    Tab:AddToggle("🛌 مصعد فيزيائي نائم (FE Sleep Lift)", function(active)  
        isCarrying = active  
        local char = lp.Character  
          
        if active then  
            if not _G.CrypticTarget or not _G.CrypticTarget.Character then  
                isCarrying = false  
                SendRobloxNotification("Cryptic Hub", "⚠️ حدد لاعباً أولاً من مربع البحث!")  
                return  
            end  
              
            -- تجميد حركة شخصيتك (عشان تبان كأنها لوح ميت)  
            if char then  
                local hum = char:FindFirstChildOfClass("Humanoid")  
                if hum then hum.PlatformStand = true end  
            end  
              
            liftHeight = -7 -- نبدأ من تحت الهدف بـ 7 مسامير (تحت الأرض)  
            SendRobloxNotification("Cryptic Hub", "🚀 شخصيتك تخرج الآن من تحت الأرض...")  
        else  
            -- إرجاع شخصيتك لوضعها الطبيعي  
            if char then  
                local hum = char:FindFirstChildOfClass("Humanoid")  
                if hum then hum.PlatformStand = false end  
            end  
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف الرفع الفيزيائي")  
        end  
    end)  
  
    -- [[ 3. المحرك الفيزيائي (العمل الحقيقي هنا) ]]  
    runService.Heartbeat:Connect(function()  
        if not isCarrying or not _G.CrypticTarget then return end  
          
        local char = lp.Character  
        local root = char and char:FindFirstChild("HumanoidRootPart")  
        local targetChar = _G.CrypticTarget.Character  
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")  
  
        if root and targetRoot then  
            -- تفعيل Anti-Fling و Noclip لشخصيتك  
            for _, part in pairs(char:GetDescendants()) do  
                if part:IsA("BasePart") then  
                    -- نجعل الجزء الأساسي فقط صلب لرفع الخصم  
                    if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then  
                        part.CanCollide = true  
                    else  
                        -- الأطراف Noclip عشان ما تضرب في الماب وتسوي Fling  
                        part.CanCollide = false  
                    end  
                    part.Massless = true  
                end  
            end  
  
            -- زيادة الارتفاع ببطء شديد  
            liftHeight = liftHeight + liftSpeed  
              
            -- أخذ موقع الخصم الحالي في X و Z  
            local tPos = targetRoot.Position  
              
            -- تطبيق وضعية النوم (90 درجة) والصعود من تحت الأرض  
            root.CFrame = CFrame.new(tPos.X, tPos.Y + liftHeight, tPos.Z) * CFrame.Angles(math.rad(90), 0, 0)  
              
            -- الدفع الفيزيائي للسيرفر (FE) لإجبار الخصم على الطيران
            root.Velocity = Vector3.new(0, 15, 0)  
              
            -- تصفير دوران شخصيتك عشان ما تتشقلب (Anti-Fling)  
            root.RotVelocity = Vector3.new(0, 0, 0)  
        end  
    end)  
end
