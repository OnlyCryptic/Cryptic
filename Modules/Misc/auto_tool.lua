-- [[ Cryptic Hub - أداة الحركة التلقائية (Auto Rig Tool) ]]
-- المطور: يامي (Yami) | الميزات: كشف R6/R15، استرجاع بعد الموت، ترتيب في الخانة 2

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer
    
    local isActive = false
    local toolNames = {"Jerk Off", "Jerk Off R15"} -- أسماء الأدوات كما تظهر في الحقيبة

    -- دالة الإشعارات
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title, Text = text, Duration = 5
            })
        end)
    end

    -- دالة ترتيب الأداة في الخانة رقم 2
    local function ForceSlot2(tool)
        local backpack = lp.Backpack
        local tools = backpack:GetChildren()
        
        -- إذا كانت الحقيبة فاضية أو الأداة هي الوحيدة، ما نقدر نحطها رقم 2
        if #tools < 2 then return end

        -- محاولة بسيطة لإعادة الترتيب (روبلوكس يرتب حسب وقت الدخول)
        -- نخرج الأداة ونرجعها عشان تصير آخر شيء، أو نحاول التلاعب بالترتيب
        -- ملاحظة: ترتيب الخانات برمجياً 100% صعب لأن روبلوكس يقيد هذا الشيء، لكن سنحاول.
        
        -- الطريقة الأفضل: إعطاء الأداة للاعب، ثم إعادة ترتيبها إذا أمكن
        tool.Parent = backpack
    end

    -- دالة فحص وتشغيل السكربت
    local function CheckAndEquip()
        if not isActive then return end
        
        local char = lp.Character
        if not char or not char:FindFirstChild("Humanoid") then return end
        
        local hum = char:FindFirstChild("Humanoid")
        local backpack = lp.Backpack
        local foundTool = nil

        -- 1. البحث عن الأداة (هل هي معك أصلاً؟)
        for _, name in pairs(toolNames) do
            if char:FindFirstChild(name) then foundTool = char[name] break end
            if backpack:FindFirstChild(name) then foundTool = backpack[name] break end
        end

        -- 2. إذا الأداة مو معك، شغل السكربت المناسب
        if not foundTool then
            if hum.Health > 0 then
                if hum.RigType == Enum.HumanoidRigType.R15 then
                    -- تشغيل رابط R15
                    loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
                else
                    -- تشغيل رابط R6
                    loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))()
                end
                
                -- انتظار بسيط عشان الأداة توصل
                task.wait(0.5)
                
                -- محاولة وضعها في الخانة 2 (بعد ما توصل)
                local newTool
                for _, name in pairs(toolNames) do
                    if backpack:FindFirstChild(name) then newTool = backpack[name] break end
                end
                
                if newTool then
                   -- هنا نحاول نحطها رقم 2، بسحبها وإرجاعها لو فيه أدوات قبلها
                   -- (هذا يعتمد على ترتيب دخول الأدوات للحقيبة)
                   SendRobloxNotification("Cryptic Hub", "🔧 تم جلب الأداة لنوع: " .. (hum.RigType == Enum.HumanoidRigType.R15 and "R15" or "R6"))
                end
            end
        end
    end

    -- الزر
    Tab:AddToggle("أداة عاده سريه / Auto Jerk", function(state)
        isActive = state
        if state then
            SendRobloxNotification("Cryptic Hub", "✅ تم التفعيل: سيتم جلب الأداة تلقائياً عند الموت.")
            CheckAndEquip() -- تشغيل فوري
            
            -- حلقة تكرار للتأكد من وجود الأداة دائماً (كل ثانية)
            task.spawn(function()
                while isActive do
                    task.wait(1)
                    CheckAndEquip()
                end
            end)
        else
            SendRobloxNotification("Cryptic Hub", "❌ تم الإيقاف.")
        end
    end)
end