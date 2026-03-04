-- [[ Cryptic Hub - أداة الحركة الذكية (Smart Rig Tool V3.1) ]]
-- المطور: يامي (Yami) | الميزات: فحص العظام (R15/R6)، إجبار الخانة 2، استرجاع وترتيب بعد الموت، نظام احتياطي

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    
    local isActive = false
    local isProcessing = false
    local toolNames = {["Jerk Off"] = true, ["Jerk Off R15"] = true}
    
    -- متغيرات لتتبع الموت والعودة
    local lastCharacter = nil
    local hasSortedThisLife = false

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
        
        if hum then
            if hum.RigType == Enum.HumanoidRigType.R15 then return "R15" end
            if hum.RigType == Enum.HumanoidRigType.R6 then return "R6" end
        end

        if char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("RightFoot") then
            return "R15"
        elseif char:FindFirstChild("Torso") and not char:FindFirstChild("UpperTorso") then
            return "R6"
        end

        return "Unknown"
    end

    -- [[ دالة التفعيل الاحتياطي (تحميل الـ R15 والـ R6 معاً) ]]
    local function LoadBothScripts()
        pcall(function()
            loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))() -- R15
            task.wait(0.5)
            loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))() -- R6
        end)
    end

    -- دالة ترتيب الحقيبة (إجبار الخانة 2)
    local function EnforceSlot2(targetTool)
        local backpack = lp.Backpack
        local otherTools = {}

        for _, t in pairs(backpack:GetChildren()) do
            if not toolNames[t.Name] and t ~= targetTool then
                table.insert(otherTools, t)
            end
        end

        if #otherTools > 0 then
            local firstTool = otherTools[1]
            
            -- نستخدم مجلد وهمي مؤقت لتفريغ الحقيبة بدون تجهيز (Equip) عشوائي يسبب مشاكل
            local tempFolder = Instance.new("Folder")
            firstTool.Parent = tempFolder
            targetTool.Parent = tempFolder
            for i = 2, #otherTools do otherTools[i].Parent = tempFolder end

            task.wait(0.05)

            -- إعادة التعبئة بالترتيب المطلوب: 1- أداة عشوائية، 2- أداتنا، ثم الباقي
            firstTool.Parent = backpack
            targetTool.Parent = backpack
            for i = 2, #otherTools do otherTools[i].Parent = backpack end
            
            tempFolder:Destroy()
            return true -- نجح الترتيب
        else
            return false -- فشل الترتيب (لا توجد أداة أخرى لتكون رقم 1)
        end
    end

    -- العملية الرئيسية
    local function ExecuteToolProcess()
        if isProcessing then return end
        isProcessing = true
        
        local char = lp.Character
        if not char then isProcessing = false return end

        -- فحص إذا اللاعب مات ورجع بشخصية جديدة (Respawn)
        if lastCharacter ~= char then
            lastCharacter = char
            hasSortedThisLife = false -- تصفير حالة الترتيب للحياة الجديدة
            task.wait(1) -- انتظار بسيط حتى تُحمل الأدوات الافتراضية
        end
        
        local foundTool = nil
        for _, t in pairs(char:GetChildren()) do if toolNames[t.Name] then foundTool = t break end end
        if not foundTool then 
            for _, t in pairs(lp.Backpack:GetChildren()) do if toolNames[t.Name] then foundTool = t break end end 
        end

        local rigType = DetectRigType(char)

        -- إذا الأداة غير موجودة بتاتاً (تم جلبها لأول مرة أو بعد الموت)
        if not foundTool then
            if rigType == "R15" then
                SendRobloxNotification("Cryptic Hub", "🦴 تم الكشف: R15 - جاري الجلب...")
                pcall(function() loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))() end)
            elseif rigType == "R6" then
                SendRobloxNotification("Cryptic Hub", "🦴 تم الكشف: R6 - جاري الجلب...")
                pcall(function() loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))() end)
            else
                -- فشل كشف النوع (الخطة الاحتياطية)
                LoadBothScripts()
                SendRobloxNotification("Cryptic Hub", "⚠️ لم نتمكن من كشف النوع! تم تفعيل الاثنين، شيك انفتوري حقك.")
                hasSortedThisLife = true -- تم التنبيه، لا داعي للتكرار
            end

            -- انتظار وصول الأداة
            local tries = 0
            repeat 
                task.wait(0.5)
                tries = tries + 1
                foundTool = lp.Backpack:FindFirstChild("Jerk Off") or lp.Backpack:FindFirstChild("Jerk Off R15") or char:FindFirstChild("Jerk Off") or char:FindFirstChild("Jerk Off R15")
            until foundTool or tries > 10
        end

        -- إذا تم العثور على الأداة ولكن لم يتم ترتيبها في هذه الحياة (بعد الموت أو التفعيل الأول)
        if foundTool and not hasSortedThisLife then
            -- التأكد أن الأداة في الحقيبة وليس في يد اللاعب قبل الترتيب
            if foundTool.Parent == char then
                foundTool.Parent = lp.Backpack
            end

            local success = EnforceSlot2(foundTool)
            
            if success then
                SendRobloxNotification("Cryptic Hub", "✅ تم وضع الأداة في الخانة [2]")
            else
                -- الخطة الاحتياطية 2: إذا فشل الترتيب ولم ننفذ الاحتياط مسبقاً
                if rigType ~= "Unknown" then
                    LoadBothScripts()
                    SendRobloxNotification("Cryptic Hub", "⚠️ ما قدرنا نحطها بخانة 2! تم تفعيل الاثنين، شيك انفتوري حقك.")
                end
            end
            
            -- تم إنجاز المهمة لهذه الحياة، نوقف الفحص العشوائي لعدم إزعاج اللاعب
            hasSortedThisLife = true 
        end
        
        task.wait(1)
        isProcessing = false
    end

    Tab:AddToggle("أداة عاده سريه / Auto Jerk (استغفر الله لا تستعملها)", function(state)
        isActive = state
        if state then
            SendRobloxNotification("Cryptic Hub", "🔄 تفعيل الفحص الذكي (Smart Rig Detect)...")
            
            -- تهيئة المتغيرات لضمان الترتيب عند التشغيل
            lastCharacter = nil
            hasSortedThisLife = false

            task.spawn(function()
                while isActive do
                    if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Health > 0 then
                        ExecuteToolProcess()
                    end
                    task.wait(2) -- فحص دوري
                end
            end)
        else
            SendRobloxNotification("Cryptic Hub", "❌ تم الإيقاف")
        end
    end)
end
