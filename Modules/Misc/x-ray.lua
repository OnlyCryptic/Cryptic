-- [[ Cryptic Hub - Map X-Ray (Anti-Crash & Smooth) ]]
-- المطور: يامي | الوصف: رؤية عبر الجدران مع تحكم بالشفافية وحماية من اللاق

local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

return function(Tab, UI)
    local isXRayOn = false
    local xrayTransparency = 0.5 -- الشفافية الافتراضية (50%)
    local originalTransparencies = {} -- جدول لحفظ الشفافية الأصلية لكل قطعة

    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3})
        end)
    end

    -- 🟢 دالة ذكية للتحقق مما إذا كانت القطعة تابعة لأي لاعب أو للكاميرا
    local function IsPlayerPart(part)
        -- حماية أسلحة منظور الشخص الأول (Viewmodels)
        if part:IsDescendantOf(workspace.CurrentCamera) then return true end
        
        -- التحقق من شخصيات اللاعبين
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and part:IsDescendantOf(player.Character) then
                return true
            end
        end
        return false
    end

    -- 🟢 تفعيل الإكس راي
    local function EnableXRay()
        isXRayOn = true
        local partsScanned = 0

        -- جلب كل القطع في اللعبة
        for _, v in ipairs(workspace:GetDescendants()) do
            if not isXRayOn then break end -- إيقاف فوري لو المستخدم طفاه فجأة
            
            -- التأكد أنها قطعة قابلة للتعديل، وليست أرضية طبيعية (Terrain)، وليست للاعب
            if v:IsA("BasePart") and v.Name ~= "Terrain" and not IsPlayerPart(v) then
                -- حفظ الشفافية الأصلية لأول مرة فقط
                if not originalTransparencies[v] then
                    originalTransparencies[v] = v.Transparency
                end
                
                -- تطبيق شفافية الإكس راي
                v.Transparency = xrayTransparency
            end

            -- 🔴 السر لمنع الكراش: إراحة المعالج كل 1000 قطعة
            partsScanned = partsScanned + 1
            if partsScanned % 1000 == 0 then task.wait() end
        end
    end

    -- 🟢 إيقاف الإكس راي واسترجاع الماب
    local function DisableXRay()
        isXRayOn = false
        for part, originalTrans in pairs(originalTransparencies) do
            if part and part.Parent then
                part.Transparency = originalTrans
            end
        end
        -- تفريغ الجدول لتوفير الذاكرة (الرام)
        originalTransparencies = {}
    end

    -- ==========================================
    -- واجهة المستخدم (UI)
    -- ==========================================
    
    Tab:AddToggle("إكس راي (رؤية الجدران) / Map X-Ray", function(state)
        if state then
            Notify("Cryptic Hub 👁️", "جاري تفعيل الإكس راي... (قد يستغرق ثواني في المابات الضخمة)\nEnabling X-Ray...")
            EnableXRay()
            if isXRayOn then
                Notify("تفعيل / Applied ✅", "تم تفعيل الرؤية عبر الجدران!\nX-Ray is active!")
            end
        else
            DisableXRay()
            Notify("إيقاف / Restored 🔄", "تم إرجاع الماب لطبيعته!\nMap restored to normal!")
        end
    end)

    Tab:AddSlider("درجة الشفافية / X-Ray Opacity", 10, 100, 50, function(value)
        -- تحويل القيمة من (10-100) إلى (0.1 - 1.0)
        xrayTransparency = value / 100
        
        -- تحديث الشفافية مباشرة إذا كان الإكس راي مفعلاً (بدون إعادة مسح الماب بالكامل لتجنب اللاق)
        if isXRayOn then
            for part, _ in pairs(originalTransparencies) do
                if part and part.Parent then
                    part.Transparency = xrayTransparency
                end
            end
        end
    end)

    Tab:AddLine()
end
