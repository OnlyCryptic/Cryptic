-- [[ Cryptic Hub - نسخ شخصية الهدف الكاملة V3.0 ]]
-- الطريقة: HumanoidDescription من شخصية الهدف الحية مباشرة

return function(Tab, UI)
    local Players    = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp         = Players.LocalPlayer

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = ar .. "\n" .. en, Duration = 6
            })
        end)
    end

    -- ============================================================
    -- الطريقة الأولى: من HumanoidDescription الخاص بيوزر الهدف
    -- (تجيب كل شيء: ملابس، اكسسوارات، ألوان، مقاسات، أنيميشنز)
    -- ============================================================
    local function CopyViaDescription(targetPlayer)
        local char = lp.Character
        local myHum = char and char:FindFirstChildOfClass("Humanoid")
        if not myHum then return false end

        local ok, desc = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(targetPlayer.UserId)
        end)

        if ok and desc then
            pcall(function() myHum:ApplyDescription(desc) end)
            return true
        end
        return false
    end

    -- ============================================================
    -- الطريقة الثانية: نسخ مباشر من شخصية الهدف الحية في السيرفر
    -- (أسرع + تشمل اكسسوارات ومحتويات الشخصية اللحظية)
    -- ============================================================
    local function CopyFromLiveCharacter(targetPlayer)
        local myChar    = lp.Character
        local myHum     = myChar and myChar:FindFirstChildOfClass("Humanoid")
        local targetChar = targetPlayer.Character

        if not myChar or not myHum or not targetChar then return false end

        -- 1. احذف كل الاكسسوارات والملابس والألوان الحالية
        for _, obj in pairs(myChar:GetChildren()) do
            if obj:IsA("Accessory")     or obj:IsA("Shirt")
            or obj:IsA("Pants")         or obj:IsA("ShirtGraphic")
            or obj:IsA("BodyColors")    or obj:IsA("SpecialMesh") then
                obj:Destroy()
            end
        end

        -- 2. انسخ من شخصية الهدف
        for _, obj in pairs(targetChar:GetChildren()) do
            -- اكسسوارات + ملابس + ألوان
            if obj:IsA("Accessory") or obj:IsA("Shirt")
            or obj:IsA("Pants")     or obj:IsA("ShirtGraphic")
            or obj:IsA("BodyColors") then
                local clone = obj:Clone()
                clone.Parent = myChar
            end
        end

        -- 3. نسخ ألوان الأجزاء مباشرة (لو BodyColors ما شتغلت)
        local partNames = {"Head","Torso","UpperTorso","LowerTorso",
                           "LeftArm","RightArm","LeftLeg","RightLeg",
                           "LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm",
                           "LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg",
                           "LeftFoot","RightFoot","LeftHand","RightHand"}
        for _, name in ipairs(partNames) do
            local myPart     = myChar:FindFirstChild(name)
            local targetPart = targetChar:FindFirstChild(name)
            if myPart and targetPart and myPart:IsA("BasePart") then
                myPart.Color         = targetPart.Color
                myPart.Material      = targetPart.Material
                myPart.Reflectance   = targetPart.Reflectance
            end
        end

        -- 4. نسخ HumanoidDescription (مقاسات الجسم + الأنيميشنز)
        local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
        if targetHum then
            local ok, targetDesc = pcall(function()
                return targetHum:GetAppliedDescription()
            end)
            if ok and targetDesc then
                -- نحتفظ بالـ assets اللي نسخناها يدوياً ونطبق الباقي
                local myDesc = myHum:GetAppliedDescription()

                -- مقاسات الجسم
                myDesc.HeightScale     = targetDesc.HeightScale
                myDesc.WidthScale      = targetDesc.WidthScale
                myDesc.HeadScale       = targetDesc.HeadScale
                myDesc.DepthScale      = targetDesc.DepthScale
                myDesc.BodyTypeScale   = targetDesc.BodyTypeScale
                myDesc.ProportionScale = targetDesc.ProportionScale

                -- الأنيميشنز
                myDesc.ClimbAnimation  = targetDesc.ClimbAnimation
                myDesc.FallAnimation   = targetDesc.FallAnimation
                myDesc.IdleAnimation   = targetDesc.IdleAnimation
                myDesc.JumpAnimation   = targetDesc.JumpAnimation
                myDesc.RunAnimation    = targetDesc.RunAnimation
                myDesc.SwimAnimation   = targetDesc.SwimAnimation
                myDesc.WalkAnimation   = targetDesc.WalkAnimation

                -- الوجه والرأس والجسم
                myDesc.Face            = targetDesc.Face
                myDesc.Head            = targetDesc.Head
                myDesc.Torso           = targetDesc.Torso
                myDesc.RightArm        = targetDesc.RightArm
                myDesc.LeftArm         = targetDesc.LeftArm
                myDesc.RightLeg        = targetDesc.RightLeg
                myDesc.LeftLeg         = targetDesc.LeftLeg

                -- الملابس
                myDesc.Shirt              = targetDesc.Shirt
                myDesc.Pants              = targetDesc.Pants
                myDesc.GraphicTShirt      = targetDesc.GraphicTShirt

                -- الاكسسوارات
                myDesc.HatAccessory       = targetDesc.HatAccessory
                myDesc.HairAccessory      = targetDesc.HairAccessory
                myDesc.FaceAccessory      = targetDesc.FaceAccessory
                myDesc.NeckAccessory      = targetDesc.NeckAccessory
                myDesc.ShouldersAccessory = targetDesc.ShouldersAccessory
                myDesc.FrontAccessory     = targetDesc.FrontAccessory
                myDesc.BackAccessory      = targetDesc.BackAccessory
                myDesc.WaistAccessory     = targetDesc.WaistAccessory

                -- الألوان
                myDesc.HeadColor          = targetDesc.HeadColor
                myDesc.TorsoColor         = targetDesc.TorsoColor
                myDesc.LeftArmColor       = targetDesc.LeftArmColor
                myDesc.RightArmColor      = targetDesc.RightArmColor
                myDesc.LeftLegColor       = targetDesc.LeftLegColor
                myDesc.RightLegColor      = targetDesc.RightLegColor

                pcall(function() myHum:ApplyDescription(myDesc) end)
            end
        end

        return true
    end

    -- ============================================================
    -- دالة النسخ الرئيسية (تجرب الطريقتين)
    -- ============================================================
    local function ApplyAppearance(targetPlayer)
        if not targetPlayer then
            Notify("⚠️ حدد لاعباً أولاً!", "Select a player first!")
            return
        end
        if not targetPlayer.Character then
            Notify("⚠️ شخصية الهدف غير موجودة في السيرفر!", "Target has no character!")
            return
        end

        Notify("⏳ جاري النسخ...", "Copying, please wait...")

        task.spawn(function()
            -- نجرب الطريقة المباشرة من الشخصية الحية أولاً (أدق وأشمل)
            local success = CopyFromLiveCharacter(targetPlayer)

            if success then
                Notify("✅ تم نسخ شخصية: " .. targetPlayer.DisplayName, "Copied: " .. targetPlayer.DisplayName)
            else
                -- طريقة بديلة من API
                success = CopyViaDescription(targetPlayer)
                if success then
                    Notify("✅ تم نسخ شخصية: " .. targetPlayer.DisplayName, "Copied: " .. targetPlayer.DisplayName)
                else
                    Notify("❌ فشل النسخ، حاول مرة ثانية.", "Copy failed, try again.")
                end
            end
        end)
    end

    -- ============================================================
    -- استعادة المظهر الأصلي
    -- ============================================================
    local function RestoreAppearance()
        local char  = lp.Character
        local myHum = char and char:FindFirstChildOfClass("Humanoid")
        if not myHum then
            Notify("❌ شخصيتك غير جاهزة!", "Your character is not ready!")
            return
        end

        task.spawn(function()
            local ok, desc = pcall(function()
                return Players:GetHumanoidDescriptionFromUserId(lp.UserId)
            end)
            if ok and desc then
                pcall(function() myHum:ApplyDescription(desc) end)
                Notify("🔄 تم استعادة مظهرك!", "Appearance restored!")
            else
                Notify("❌ فشل الاستعادة.", "Restore failed.")
            end
        end)
    end

    -- ============================================================
    -- الأزرار
    -- ============================================================
    Tab:AddButton("🪞 انسخ شخصية الهدف / Copy Target", function()
        ApplyAppearance(_G.ArwaTarget)
    end)

    Tab:AddButton("🔄 استعادة مظهرك / Restore Appearance", function()
        RestoreAppearance()
    end)

end
