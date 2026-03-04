-- [[ Cryptic Hub - أداة الحركة الذكية (Smart Rig Tool V3) ]]
-- المطور: يامي (Yami) | الميزات: فحص العظام (R15/R6)، إجبار الخانة 2، استرجاع بعد الموت

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    
    local isActive = false
    local isProcessing = false
    local toolNames = {["Jerk Off"] = true, ["Jerk Off R15"] = true}

    -- دالة الإشعارات
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title, Text = text, Duration = 5
            })
        end)
    end

    -- [[ دالة كشف النوع المتقدمة ]]
    local function DetectRigType(char)
        local hum = char:FindFirstChild("Humanoid")
        
        -- الطريقة 1: الفحص الرسمي
        if hum then
            if hum.RigType == Enum.HumanoidRigType.R15 then return "R15" end
            if hum.RigType == Enum.HumanoidRigType.R6 then return "R6" end
        end

        -- الطريقة 2: فحص العظام (للمابات التي لا تحدد النوع)
        if char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("RightFoot") then
            return "R15" -- وجود أجزاء R15 يعني أنك R15
        elseif char:FindFirstChild("Torso") and not char:FindFirstChild("UpperTorso") then
            return "R6" -- وجود Torso فقط يعني R6
        end

        return "Unknown"
    end

    -- دالة ترتيب الحقيبة (إجبار الخانة 2)
    local function EnforceSlot2(targetTool)
        local backpack = lp.Backpack
        local otherTools = {}

        -- جمع الأدوات الأخرى
        for _, t in pairs(backpack:GetChildren()) do
            if not toolNames[t.Name] and t ~= targetTool then
                table.insert(otherTools, t)
            end
        end

        if #otherTools > 0 then
            -- تفريغ الحقيبة لإعادة الترتيب
            local firstTool = otherTools[1]
            
            targetTool.Parent = lp
            firstTool.Parent = lp
            for i = 2, #otherTools do otherTools[i].Parent = lp end

            task.wait(0.05)

            -- إعادة التعبئة: 1- أداة عشوائية، 2- أداتنا
            firstTool.Parent = backpack
            targetTool.Parent = backpack
            
            -- الباقي
            for i = 2, #otherTools do otherTools[i].Parent = backpack end
            
            SendRobloxNotification("Cryptic Hub", "✅ تم وضع الأداة في الخانة [2]")
        else
            SendRobloxNotification("Cryptic Hub", "⚠️ الأداة معك ولكن تحتاج أداة أخرى لتصبح رقم [2]")
        end
    end

    -- العملية الرئيسية
    local function ExecuteToolProcess()
        if isProcessing then return end
        isProcessing = true
        
        local char = lp.Character
        if not char then isProcessing = false return end
        
        -- التأكد من خلو الحقيبة والشخصية من الأداة قبل جلبها مرة أخرى
        local foundTool = nil
        for _, t in pairs(char:GetChildren()) do if toolNames[t.Name] then foundTool = t break end end
        if not foundTool then 
            for _, t in pairs(lp.Backpack:GetChildren()) do if toolNames[t.Name] then foundTool = t break end end 
        end

        if not foundTool then
            -- تحديد النوع بدقة
            local rigType = DetectRigType(char)
            
            if rigType == "R15" then
                SendRobloxNotification("Cryptic Hub", "🦴 تم الكشف: R15 - جاري الجلب...")
                loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
            elseif rigType == "R6" then
                SendRobloxNotification("Cryptic Hub", "🦴 تم الكشف: R6 - جاري الجلب...")
                loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))()
            else
                -- إذا فشل كل شيء، نجرب R15 كافتراضي
                SendRobloxNotification("Cryptic Hub", "⚠️ لم يتم تحديد النوع! تجربة R15...")
                loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
            end

            -- انتظار وصول الأداة ثم ترتيبها
            task.spawn(function()
                local tries = 0
                repeat 
                    task.wait(0.5)
                    tries = tries + 1
                    foundTool = lp.Backpack:FindFirstChild("Jerk Off") or lp.Backpack:FindFirstChild("Jerk Off R15")
                until foundTool or tries > 10
                
                if foundTool then
                    EnforceSlot2(foundTool)
                end
            end)
        else
            -- الأداة موجودة، فقط نتأكد من الترتيب
           -- EnforceSlot2(foundTool) -- (اختياري: فعل هذا السطر لو تبي يرتبها كل شوي)
        end
        
        task.wait(1)
        isProcessing = false
    end

    Tab:AddToggle("أداة الحركة الذكية / Auto Jerk", function(state)
        isActive = state
        if state then
            SendRobloxNotification("Cryptic Hub", "🔄 تفعيل الفحص الذكي (Smart Rig Detect)...")
            
            task.spawn(function()
                while isActive do
                    if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Health > 0 then
                        ExecuteToolProcess()
                    end
                    task.wait(2) -- فحص كل ثانيتين
                end
            end)
        else
            SendRobloxNotification("Cryptic Hub", "❌ تم الإيقاف")
        end
    end)
end