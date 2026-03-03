ودا  
-- [[ Cryptic Hub - المصعد الفيزيائي المطور (Sleeping Elevator) ]]  
-- المطور: Cryptic | الميزات: وضعية النوم، خروج من تحت الأرض ببطء، Anti-Fling، Noclip  
  
return function(Tab, UI)  
    local runService = game:GetService("RunService")  
    local players = game:GetService("Players")  
    local lp = players.LocalPlayer  
      
    local isCarrying = false  
    local liftHeight = 0  
    local liftSpeed = 0.03 -- سرعة الصعود البطيئة جداً من تحت الأرض  
    local startY = 0 -- لتسجيل نقطة البداية تحت الأرض  
  
    -- 1. نظام البحث الذكي (جاهز ومصلح)  
    local InputField = Tab:AddInput("البحث عن لاعب", "اكتب اليوزر وأغلق الكيبورد...", function() end)  
  
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
            UI:Notify("🎯 تم قفل الهدف: " .. bestMatch.DisplayName)  
        else  
            _G.CrypticTarget = nil  
            UI:Notify("❌ لم يتم العثور على اللاعب")  
        end  
    end)  
  
    -- 2. زر التفعيل  
    Tab:AddToggle("🛌 مصعد فيزيائي نائم (FE Sleep Lift)", function(active)  
        isCarrying = active  
        local char = lp.Character  
          
        if active then  
            if not _G.CrypticTarget or not _G.CrypticTarget.Character then  
                isCarrying = false  
                UI:Notify("⚠️ حدد لاعباً أولاً!")  
                return  
            end  
              
            -- تجميد حركة شخصيتك (عشان تبان كأنها لوح ميت)  
            if char then  
                local hum = char:FindFirstChildOfClass("Humanoid")  
                if hum then hum.PlatformStand = true end  
            end  
              
            liftHeight = -7 -- نبدأ من تحت الهدف بـ 7 مسامير (تحت الأرض)  
            UI:Notify("🚀 شخصيتك تخرج الآن من تحت الأرض بوضعية النوم...")  
        else  
            -- إرجاع شخصيتك لوضعها الطبيعي  
            if char then  
                local hum = char:FindFirstChildOfClass("Humanoid")  
                if hum then hum.PlatformStand = false end  
            end  
            UI:Notify("❌ تم إيقاف الرفع الفيزيائي")  
        end  
    end)  
  
    -- 3. المحرك الفيزيائي (العمل الحقيقي هنا)  
    runService.Heartbeat:Connect(function()  
        if not isCarrying or not _G.CrypticTarget then return end  
          
        local char = lp.Character  
        local root = char and char:FindFirstChild("HumanoidRootPart")  
        local targetChar = _G.CrypticTarget.Character  
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")  
  
        if root and targetRoot then  
            -- [[ تفعيل Anti-Fling و Noclip لشخصيتك ]]  
            for _, part in pairs(char:GetDescendants()) do  
                if part:IsA("BasePart") then  
                    -- نجعل الجزء الأساسي (Root/Torso) فقط صلب لرفع الخصم  
                    if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then  
                        part.CanCollide = true  
                    else  
                        -- الأطراف (اليدين والرجلين) Noclip عشان ما تضرب في الماب وتسوي Fling  
                        part.CanCollide = false  
                    end  
                    part.Massless = true  
                end  
            end  
  
            -- زيادة الارتفاع ببطء شديد  
            liftHeight = liftHeight + liftSpeed  
              
            -- أخذ موقع الخصم الحالي في X و Z  
            local tPos = targetRoot.Position  
              
            -- [[ تطبيق وضعية النوم (90 درجة) والصعود من تحت الأرض ]]  
            -- ندمج الإحداثيات (تحت الخصم) مع الدوران (كأنك نايم على ظهرك)  
            root.CFrame = CFrame.new(tPos.X, tPos.Y + liftHeight, tPos.Z) * CFrame.Angles(math.rad(90), 0, 0)  
              
            -- [[ الدفع الفيزيائي للسيرفر (FE) ]]  
            -- نعطي شخصيتك قوة دفع للأعلى عشان السيرفر يقتنع إنك منصة ترتفع  
            -- هذا اللي بيخلي الخصم يطير غصب عنه لما تلامس رجله  
            root.Velocity = Vector3.new(0, 15, 0)  
              
            -- تصفير دوران شخصيتك عشان ما تتشقلب (Anti-Fling)  
            root.RotVelocity = Vector3.new(0, 0, 0)  
        end  
    end)  
end  
