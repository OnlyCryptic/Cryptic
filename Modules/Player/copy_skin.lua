-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (نظام الدمية / Puppet Morph) ]]
-- المطور: يامي | الوصف: نسخ جبري لشكل الجسم 100% (R15 و R6) باستخدام تقنية الدرع الخارجي

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    local isToggleOn = false
    local originalState = nil 

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 }) end)
    end

    -- ==========================================
    -- نظام حفظ سكنك الأصلي لضمان الاسترجاع الدقيق
    -- ==========================================
    local function SaveOriginalState(char)
        if originalState then return end
        originalState = { Props = {}, Anims = {}, DisplayName = lp.DisplayName }

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then originalState.DisplayName = hum.DisplayName end

        -- حفظ شفافية كل جزء وحالة تشغيل المؤثرات
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                originalState.Props[v] = { Transparency = v.Transparency }
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Highlight") or v:IsA("ForceField") then
                originalState.Props[v] = { Enabled = v.Enabled }
            end
        end

        -- حفظ الانيميشن
        local anim = char:FindFirstChild("Animate")
        if anim then
            for _, obj in ipairs(anim:GetChildren()) do
                if obj:IsA("StringValue") then
                    local animData = { Value = obj.Value, Anims = {} }
                    for _, a in ipairs(obj:GetChildren()) do
                        if a:IsA("Animation") then animData.Anims[a.Name] = a.AnimationId end
                    end
                    originalState.Anims[obj.Name] = animData
                end
            end
        end
    end

    local function RestoreOriginalState()
        local myChar = lp.Character
        if not myChar or not originalState then return end

        -- تدمير الدمية المستنسخة
        local morph = myChar:FindFirstChild("FakeMorph")
        if morph then morph:Destroy() end

        -- استرجاع الألوان والمؤثرات الأصلية
        for obj, props in pairs(originalState.Props) do
            if obj and obj.Parent then
                if props.Transparency ~= nil then obj.Transparency = props.Transparency end
                if props.Enabled ~= nil then obj.Enabled = props.Enabled end
            end
        end

        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then hum.DisplayName = originalState.DisplayName end

        -- استرجاع مشيتك
        local anim = myChar:FindFirstChild("Animate")
        if anim then
            for objName, data in pairs(originalState.Anims) do
                local myObj = anim:FindFirstChild(objName)
                if myObj and myObj:IsA("StringValue") then
                    myObj.Value = data.Value
                    for animName, animId in pairs(data.Anims) do
                        local myAnim = myObj:FindFirstChild(animName)
                        if myAnim and myAnim:IsA("Animation") then myAnim.AnimationId = animId end
                    end
                end
            end
        end
    end

    -- ==========================================
    -- دالة تركيب الدمية فوقك (النسخ الفعلي)
    -- ==========================================
    local function ApplyPuppetMorph(sourceChar)
        local myChar = lp.Character
        if not myChar or not sourceChar then return end

        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        local sourceHum = sourceChar:FindFirstChildOfClass("Humanoid")
        if not myHum or not sourceHum then return end

        -- التأكد من أن نوع الجسم متطابق (عشان ما يتفكك)
        if myHum.RigType ~= sourceHum.RigType then
            Notify("Cryptic Hub ⚠️", "لا يمكن نسخ السكن: أنواع الأجسام مختلفة!\nRig types must match (R6 / R15)!")
            return
        end

        -- تنظيف أي نسخ سابقة وحفظ الأصل
        RestoreOriginalState()
        SaveOriginalState(myChar)

        -- 1. إخفاء جسمك بالكامل وإطفاء مؤثراتك
        for _, v in ipairs(myChar:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Transparency = 1
            elseif v:IsA("Decal") and v.Name == "face" then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Highlight") or v:IsA("ForceField") then
                v.Enabled = false
            end
        end

        -- 2. استنساخ الهدف ليكون الدمية
        sourceChar.Archivable = true
        local morph = sourceChar:Clone()
        morph.Name = "FakeMorph"

        local morphHum = morph:FindFirstChildOfClass("Humanoid")
        if morphHum then
            morphHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            morphHum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
            morphHum.PlatformStand = true -- منعه من المشي لحاله
        end

        -- 3. تجهيز الدمية وربطها بجسمك المخفي
        for _, v in ipairs(morph:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") then
                v:Destroy()
            elseif v:IsA("Motor6D") then
                -- كسر مفاصل الجسم فقط للحفاظ على الإكسسوارات
                if not v:FindFirstAncestorOfClass("Accessory") then
                    v:Destroy()
                end
            elseif v:IsA("BasePart") then
                v.CanCollide = false
                v.Massless = true
                v.Anchored = false

                if v.Name == "HumanoidRootPart" then v.Transparency = 1 end

                -- اللحام: ربط يد الدمية بيدك المخفية، ورجل الدمية برجلك...
                local myPart = myChar:FindFirstChild(v.Name)
                if myPart and myPart:IsA("BasePart") then
                    local weld = Instance.new("Weld")
                    weld.Name = "PuppetWeld"
                    weld.Part0 = myPart
                    weld.Part1 = v
                    weld.C0 = CFrame.new()
                    weld.C1 = CFrame.new()
                    weld.Parent = v
                end
            end
        end

        -- 4. نسخ الانيميشن وتغيير الاسم
        local targetAnimate = sourceChar:FindFirstChild("Animate")
        local myAnimate = myChar:FindFirstChild("Animate")
        if targetAnimate and myAnimate then
            for _, obj in ipairs(targetAnimate:GetChildren()) do
                local myObj = myAnimate:FindFirstChild(obj.Name)
                if myObj and obj:IsA("StringValue") and myObj:IsA("StringValue") then
                    myObj.Value = obj.Value
                    for _, anim in ipairs(obj:GetChildren()) do
                        if anim:IsA("Animation") then
                            local myAnim = myObj:FindFirstChild(anim.Name)
                            if myAnim and myAnim:IsA("Animation") then myAnim.AnimationId = anim.AnimationId end
                        end
                    end
                end
            end
        end

        myHum.DisplayName = sourceHum.DisplayName
        morph.Parent = myChar
    end

    -- ==========================================
    -- بناء الواجهة
    -- ==========================================
    Tab:AddLabel("⚠️ الميزة لك فقط / Only you can see the skin")

    local PlayerDropdown = Tab:AddPlayerSelector("اختر اللاعب / Select Player", "ابحث عن لاعب / Search...", function(selected)
        targetPlayer = (typeof(selected) == "Instance" and selected:IsA("Player")) and selected or nil
        
        -- التبديل التلقائي إذا كان الزر مفعلاً
        if isToggleOn and targetPlayer and targetPlayer.Character then
            pcall(function()
                ApplyPuppetMorph(targetPlayer.Character)
                Notify("Cryptic Hub 🎭", "تم تحديث السكن إلى: " .. targetPlayer.DisplayName)
            end)
        end
    end)
    
    local function UpdateDropdown()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then table.insert(list, p) end
        end
        if PlayerDropdown and PlayerDropdown.UpdateList then PlayerDropdown.UpdateList(list) end
    end
    
    UpdateDropdown()
    Players.PlayerAdded:Connect(UpdateDropdown)
    Players.PlayerRemoving:Connect(UpdateDropdown)

    -- زر التشغيل والإيقاف
    Tab:AddToggle("تفعيل السكن المستنسخ / Copy Skin", function(state)
        isToggleOn = state
        local myChar = lp.Character
        if not myChar then return end

        if state then
            if not targetPlayer or not targetPlayer.Character then
                Notify("Cryptic Hub ⚠️", "يرجى اختيار لاعب موجود باللعبة!\nPlease select a valid player!")
                return
            end
            
            pcall(function()
                ApplyPuppetMorph(targetPlayer.Character)
                Notify("Cryptic Hub 🎭", "✅ تم نسخ الجسم بالكامل!\nFull body perfectly copied!")
            end)
        else
            pcall(function()
                RestoreOriginalState()
                Notify("Cryptic Hub 🔄", "✅ تم استرجاع سكنك الأصلي!\nOriginal skin restored!")
            end)
        end
    end)

    -- إعادة التهيئة لو متّ ورسبنت
    lp.CharacterAdded:Connect(function(newChar)
        originalState = nil 
        task.delay(1, function()
            if isToggleOn and targetPlayer and targetPlayer.Character then
                ApplyPuppetMorph(targetPlayer.Character)
            end
        end)
    end)

    Tab:AddLine()
end
