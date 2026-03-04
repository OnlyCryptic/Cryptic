-- [[ Cryptic Hub - أداة الحركة التلقائية (Auto Rig Tool V2) ]]
-- المطور: يامي (Yami) | الميزات: إجبار الخانة 2، كشف R6/R15، استرجاع بعد الموت

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    
    local isActive = false
    local checking = false
    -- أسماء الأدوات المحتملة
    local targetNames = {["Jerk Off"] = true, ["Jerk Off R15"] = true} 

    -- دالة الإشعارات الرسمية
    local function SendRobloxNotification(title, text, duration)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title, Text = text, Duration = duration or 5
            })
        end)
    end

    -- دالة ترتيب الحقيبة (Hotbar Sorter)
    local function EnforceSlot2(targetTool)
        local backpack = lp.Backpack
        local allTools = backpack:GetChildren()
        local otherTools = {}

        -- تصنيف الأدوات: الهدف vs البقية
        for _, t in pairs(allTools) do
            if t ~= targetTool then
                table.insert(otherTools, t)
            end
        end

        -- إذا كان معنا أدوات أخرى، نقدر نجبر الترتيب
        if #otherTools > 0 then
            -- 1. تفريغ الحقيبة مؤقتاً (نقل لملف اللاعب)
            -- ملاحظة: الترتيب يعتمد على من يدخل الحقيبة أولاً
            local firstTool = otherTools[1] -- بناخذ أول أداة عشان تصير رقم 1
            
            targetTool.Parent = lp 
            firstTool.Parent = lp
            
            for i = 2, #otherTools do
                otherTools[i].Parent = lp
            end

            task.wait(0.1) -- انتظار بسيط جداً للمعالجة

            -- 2. إعادة التعبئة بالترتيب المطلوب
            firstTool.Parent = backpack   -- تدخل أولاً (تصير Slot 1)
            targetTool.Parent = backpack  -- تدخل ثانياً (تصير Slot 2) غصب
            
            -- ترجيع باقي الأدوات (تصير 3 و 4 ...)
            for i = 2, #otherTools do
                otherTools[i].Parent = backpack
            end
            
            SendRobloxNotification("Cryptic Hub", "✅ تم وضع الأداة في الخانة رقم [2] بنجاح.")
        else
            -- الحالة الصعبة: اللاعب ما معه إلا أداة السكربت، فبتصير رقم 1 غصب
            SendRobloxNotification("Cryptic Hub", "⚠️ الأداة معك ولكن لا توجد أدوات أخرى لترتيبها.\n📂 يرجى فتح الحقيبة (Inventory) لاستعمالها!")
        end
    end

    -- الدالة الرئيسية للفحص والتشغيل
    local function CheckProcess()
        if checking then return end
        checking = true
        
        local char = lp.Character
        if not char or not char:FindFirstChild("Humanoid") then 
            checking = false 
            return 
        end
        
        local hum = char:FindFirstChild("Humanoid")
        local backpack = lp.Backpack
        local foundTool = nil

        -- البحث عن الأداة (هل هي موجودة؟)
        for _, t in pairs(char:GetChildren()) do
            if t:IsA("Tool") and targetNames[t.Name] then foundTool = t break end
        end
        if not foundTool then
            for _, t in pairs(backpack:GetChildren()) do
                if targetNames[t.Name] then foundTool = t break end
            end
        end

        -- إذا الأداة غير موجودة، نشغل السكربت المناسب
        if not foundTool and hum.Health > 0 then
            if hum.RigType == Enum.HumanoidRigType.R15 then
                loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
            else
                loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))()
            end
            
            -- ننتظر شوي لحد ما السكربت يعطينا الأداة
            local waitTime = 0
            repeat 
                task.wait(0.2)
                waitTime = waitTime + 0.2
                -- بحث سريع
                for _, t in pairs(backpack:GetChildren()) do
                    if targetNames[t.Name] then foundTool = t break end
                end
            until foundTool or waitTime > 3

            if foundTool then
                -- تمت إضافة الأداة، الآن نحاول ترتيبها
                EnforceSlot2(foundTool)
            end
        elseif foundTool and foundTool.Parent == backpack then
            -- الأداة موجودة لكن نتأكد من مكانها كل فترة (اختياري)
            -- EnforceSlot2(foundTool) -- (ملغاة عشان ما يسوي سبام ترتيب)
        end
        
        checking = false
    end

    -- الزر في الواجهة
    Tab:AddToggle("أداة عاده سريه / Auto Jerk", function(state)
        isActive = state
        if state then
            SendRobloxNotification("Cryptic Hub", "🔄 جاري التفعيل والكشف عن نوع الشخصية...")
            
            -- تشغيل حلقة تكرار (Loop) عشان لو مت ترجع الأداة
            task.spawn(function()
                while isActive do
                    CheckProcess()
                    task.wait(2) -- يفحص كل ثانيتين (وقت كافي للريسبون)
                end
            end)
        else
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف الاسترجاع التلقائي.")
        end
    end)
end