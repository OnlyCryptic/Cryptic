-- [[ Cryptic Hub - نسخ مظهر الهدف / Copy Skin V2.5 ]]
-- ينسخ الملابس والألوان والاكسسوارات والوجه من الهدف بدون أي التصاق

local Players    = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local lp         = Players.LocalPlayer

local COPIED_TAG = "_CrypticSkinCopy"

return function(Tab, UI)

    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local isActive = false

    -- حفظ المظهر الأصلي
    local savedShirt      = nil
    local savedPants      = nil
    local savedTShirt     = nil
    local savedBodyColors = nil
    local savedFace       = nil
    local savedAccIds     = {}  -- نحفظ asset IDs فقط مش الاكسسوارات نفسها

    -- =============================================
    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = "Cryptic Hub",
                Text     = text,
                Duration = 4,
            })
        end)
    end

    -- =============================================
    -- تنظيف كل اللي نسخناه من شخصيتك
    -- =============================================
    local function ClearCopied(myChar)
        for _, v in pairs(myChar:GetChildren()) do
            pcall(function()
                if v:GetAttribute(COPIED_TAG) then v:Destroy() end
            end)
        end
        for _, v in pairs(myChar:GetDescendants()) do
            pcall(function()
                if v:GetAttribute(COPIED_TAG) then v:Destroy() end
            end)
        end
    end

    -- =============================================
    -- حفظ مظهرك الأصلي
    -- =============================================
    local function SaveOriginal(myChar)
        local myHum = myChar:FindFirstChildOfClass("Humanoid")

        -- ملابس
        local sh = myChar:FindFirstChildWhichIsA("Shirt")
        savedShirt  = sh and sh.ShirtTemplate or ""

        local pa = myChar:FindFirstChildWhichIsA("Pants")
        savedPants  = pa and pa.PantsTemplate or ""

        local ts = myChar:FindFirstChildWhichIsA("ShirtGraphic")
        savedTShirt = ts and ts.Graphic or ""

        -- ألوان الجسد
        local bc = myChar:FindFirstChildWhichIsA("BodyColors")
        if bc then
            savedBodyColors = {
                HeadColor     = bc.HeadColor,
                TorsoColor    = bc.TorsoColor,
                LeftArmColor  = bc.LeftArmColor,
                RightArmColor = bc.RightArmColor,
                LeftLegColor  = bc.LeftLegColor,
                RightLegColor = bc.RightLegColor,
            }
        end

        -- الوجه
        savedFace = nil
        if myHum then
            local ok, desc = pcall(function() return myHum:GetAppliedDescription() end)
            if ok and desc then savedFace = desc.Face end
        end

        -- نحفظ asset IDs للاكسسوارات عشان نرجعها لاحقاً
        savedAccIds = {}
        if myHum then
            local ok, desc = pcall(function() return myHum:GetAppliedDescription() end)
            if ok and desc then
                -- نخزن الـ description كاملة عشان نرجع الاكسسوارات
                savedAccIds = desc
            end
        end
    end

    -- =============================================
    -- تطبيق مظهر الهدف
    -- =============================================
    local function ApplySkin(myChar, targetChar)
        local myHum  = myChar:FindFirstChildOfClass("Humanoid")
        local tHum   = targetChar:FindFirstChildOfClass("Humanoid")
        local myHead = myChar:FindFirstChild("Head")

        -- ══ خطوة 1: نظّف شخصيتك ═══════════════════════════════

        -- شيل الملابس القديمة
        for _, cls in ipairs({"Shirt","Pants","ShirtGraphic"}) do
            local obj = myChar:FindFirstChildWhichIsA(cls)
            if obj then obj:Destroy() end
        end

        -- شيل الاكسسوارات القديمة
        for _, acc in pairs(myChar:GetChildren()) do
            if acc:IsA("Accessory") then acc:Destroy() end
        end

        -- شيل أي حاجة منسوخة سابقاً
        ClearCopied(myChar)

        task.wait()

        -- ══ خطوة 2: انسخ الملابس والألوان والوجه ════════════════

        -- ملابس
        for _, cls in ipairs({"Shirt","Pants","ShirtGraphic"}) do
            local src = targetChar:FindFirstChildWhichIsA(cls)
            if src then
                local clone = src:Clone()
                clone:SetAttribute(COPIED_TAG, true)
                clone.Parent = myChar
            end
        end

        -- ألوان الجسد
        local tBc = targetChar:FindFirstChildWhichIsA("BodyColors")
        local mBc = myChar:FindFirstChildWhichIsA("BodyColors")
        if tBc and mBc then
            mBc.HeadColor     = tBc.HeadColor
            mBc.TorsoColor    = tBc.TorsoColor
            mBc.LeftArmColor  = tBc.LeftArmColor
            mBc.RightArmColor = tBc.RightArmColor
            mBc.LeftLegColor  = tBc.LeftLegColor
            mBc.RightLegColor = tBc.RightLegColor
        end

        -- وجه
        if tHum and myHead then
            local ok, tDesc = pcall(function() return tHum:GetAppliedDescription() end)
            if ok and tDesc and tDesc.Face ~= 0 then
                local myMesh = myHead:FindFirstChildOfClass("SpecialMesh")
                if myMesh then
                    myMesh.TextureId = "rbxassetid://" .. tDesc.Face
                    myMesh:SetAttribute(COPIED_TAG, true)
                end
            end
        end

        -- ══ خطوة 3: انسخ الاكسسوارات بـ AddAccessory ════════════
        -- AddAccessory هي الطريقة الرسمية — ما تسبب التصاق لأنها تعمل
        -- على نفس شخصيتك فقط بدون أي ربط بالمستهدف

        if myHum then
            for _, acc in pairs(targetChar:GetChildren()) do
                if acc:IsA("Accessory") then
                    local cloned = acc:Clone()

                    -- امسح كل الـ Welds والـ Motors من الكلون قبل AddAccessory
                    -- عشان ما يكون فيه أي مرجع لأجزاء شخصية المستهدف
                    for _, w in pairs(cloned:GetDescendants()) do
                        if w:IsA("Weld") or w:IsA("WeldConstraint") or w:IsA("Motor6D") then
                            w:Destroy()
                        end
                    end

                    local handle = cloned:FindFirstChild("Handle")
                    if handle then
                        handle.CanCollide = false
                        handle.Massless   = true  -- ما يأثر على الحركة
                    end

                    cloned:SetAttribute(COPIED_TAG, true)
                    -- AddAccessory تربطه بشخصيتك الصح بدون أي مشكلة
                    pcall(function() myHum:AddAccessory(cloned) end)
                end
            end
        end

        -- ══ خطوة 4: انسخ الافكتات (Highlight, Particles...) ════════

        local effectClasses = { "ParticleEmitter", "Fire", "Smoke", "Sparkles" }

        local tHL = targetChar:FindFirstChildWhichIsA("Highlight")
        if tHL then
            local clone = tHL:Clone()
            clone:SetAttribute(COPIED_TAG, true)
            clone.Parent = myChar
        end

        for _, part in pairs(targetChar:GetDescendants()) do
            if part:IsA("BasePart") then
                local myPart = myChar:FindFirstChild(part.Name)
                if myPart and myPart:IsA("BasePart") then
                    for _, eff in pairs(part:GetChildren()) do
                        for _, cls in ipairs(effectClasses) do
                            if eff:IsA(cls) then
                                local clonedEff = eff:Clone()
                                clonedEff:SetAttribute(COPIED_TAG, true)
                                clonedEff.Parent = myPart
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    -- =============================================
    -- استرجاع مظهرك الأصلي
    -- =============================================
    local function RestoreSkin(myChar)
        local myHum  = myChar:FindFirstChildOfClass("Humanoid")
        local myHead = myChar:FindFirstChild("Head")

        -- شيل اللي نسخناه
        ClearCopied(myChar)
        for _, acc in pairs(myChar:GetChildren()) do
            if acc:IsA("Accessory") then acc:Destroy() end
        end

        task.wait()

        -- أرجع الملابس
        local function restoreClothing(className, propName, savedVal)
            local obj = myChar:FindFirstChildWhichIsA(className)
            if savedVal and savedVal ~= "" then
                if not obj then
                    obj = Instance.new(className)
                    obj.Parent = myChar
                end
                obj[propName] = savedVal
            else
                if obj then obj:Destroy() end
            end
        end

        restoreClothing("Shirt",        "ShirtTemplate", savedShirt)
        restoreClothing("Pants",        "PantsTemplate", savedPants)
        restoreClothing("ShirtGraphic", "Graphic",       savedTShirt)

        -- أرجع ألوان الجسد
        if savedBodyColors then
            local bc = myChar:FindFirstChildWhichIsA("BodyColors")
            if bc then
                bc.HeadColor     = savedBodyColors.HeadColor
                bc.TorsoColor    = savedBodyColors.TorsoColor
                bc.LeftArmColor  = savedBodyColors.LeftArmColor
                bc.RightArmColor = savedBodyColors.RightArmColor
                bc.LeftLegColor  = savedBodyColors.LeftLegColor
                bc.RightLegColor = savedBodyColors.RightLegColor
            end
        end

        -- أرجع الوجه
        if savedFace and myHead then
            local myMesh = myHead:FindFirstChildOfClass("SpecialMesh")
            if myMesh then
                myMesh.TextureId = "rbxassetid://" .. savedFace
            end
        end

        -- أرجع الاكسسوارات الأصلية عبر ApplyDescription إذا كانت محفوظة
        if myHum and savedAccIds and type(savedAccIds) == "userdata" then
            pcall(function() myHum:ApplyDescription(savedAccIds) end)
        end

        savedShirt = nil; savedPants = nil; savedTShirt = nil
        savedBodyColors = nil; savedFace = nil; savedAccIds = {}
    end

    -- =============================================
    -- واجهة المستخدم
    -- =============================================
    Tab:AddToggle(T("combat.copy_skin1.label"), function(active)
        isActive = active

        if active then
            local target = _G.ArwaTarget
            if not target or not target.Character then
                isActive = false
                Notify(T("combat.common.no_target"))
                return
            end

            local myChar     = lp.Character
            local targetChar = target.Character
            if not myChar or not targetChar then
                isActive = false
                return
            end

            SaveOriginal(myChar)
            ApplySkin(myChar, targetChar)
            Notify(string.format(T("combat.copy_skin1.on_fmt"), target.DisplayName))
        else
            local myChar = lp.Character
            if myChar then RestoreSkin(myChar) end
            Notify(T("combat.copy_skin1.off"))
        end
    end)

    -- إعادة التطبيق بعد الموت
    lp.CharacterAdded:Connect(function(char)
        if not isActive then return end
        task.delay(1.5, function()
            local target = _G.ArwaTarget
            if not target or not target.Character then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            savedAccIds = {}
            SaveOriginal(char)
            ApplySkin(char, target.Character)
        end)
    end)

end
