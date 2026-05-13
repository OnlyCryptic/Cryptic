-- [[ Cryptic Hub - نسخ مظهر الهدف / Copy Skin V2.5 ]]
-- ينسخ HumanoidDescription من المستهدف ويطبقها مباشرة — بدون أي welds يدوية

local Players    = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local lp         = Players.LocalPlayer

return function(Tab, UI)

    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local isActive     = false
    local savedDesc    = nil  -- HumanoidDescription الأصلية

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
    -- حفظ مظهرك الأصلي عبر HumanoidDescription
    -- =============================================
    local function SaveOriginal(myChar)
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        if not myHum then return end
        local ok, desc = pcall(function() return myHum:GetAppliedDescription() end)
        if ok and desc then
            savedDesc = desc
        end
    end

    -- =============================================
    -- تطبيق مظهر الهدف عبر ApplyDescription
    -- =============================================
    local function ApplySkin(myChar, targetChar)
        local tHum  = targetChar:FindFirstChildOfClass("Humanoid")
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        if not tHum or not myHum then return end

        -- اجيب HumanoidDescription من المستهدف
        local ok, tDesc = pcall(function() return tHum:GetAppliedDescription() end)
        if not ok or not tDesc then return end

        -- طبّقها على شخصيتك مباشرة
        pcall(function() myHum:ApplyDescription(tDesc) end)
    end

    -- =============================================
    -- استرجاع مظهرك الأصلي
    -- =============================================
    local function RestoreSkin(myChar)
        if not savedDesc then return end
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        if not myHum then return end
        pcall(function() myHum:ApplyDescription(savedDesc) end)
        savedDesc = nil
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
            savedDesc = nil
            SaveOriginal(char)
            ApplySkin(char, target.Character)
        end)
    end)

end
