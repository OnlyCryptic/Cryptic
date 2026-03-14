-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (نظام الدرع الأجوف - Hollow Armor) ]]
-- المطور: يامي | الوصف: تحكم حر 100%، بدون تمثال، بدون تحرك عشوائي، نسخ دقيق

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
    -- نظام حفظ واسترجاع حالتك الأصلية
    -- ==========================================
    local function SaveOriginalState(char)
        if originalState then return end
        originalState = { Props = {}, Scales = {}, Anims = {}, DisplayName = lp.DisplayName }

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then 
            originalState.DisplayName = hum.DisplayName 
            local scales = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
            for _, scale in ipairs(scales) do
                local val = hum:FindFirstChild(scale)
                if val and val:IsA("NumberValue") then originalState.Scales[scale] = val.Value end
            end
        end

        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                originalState.Props[v] = { Transparency = v.Transparency }
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Highlight") or v:IsA("ForceField") then
                originalState.Props[v] = { Enabled = v.Enabled }
            end
        end

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

        local armor = myChar:FindFirstChild("CrypticArmor")
        if armor then armor:Destroy() end

        for obj, props in pairs(originalState.Props) do
            if obj and obj.Parent then
                if props.Transparency ~= nil then obj.Transparency = props.Transparency end
                if props.Enabled ~= nil then obj.Enabled = props.Enabled end
            end
        end

        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.DisplayName = originalState.DisplayName 
            for scale, val in pairs(originalState.Scales) do
                local tVal = hum:FindFirstChild(scale)
                if tVal and tVal:IsA("NumberValue") then tVal.Value = val end
            end
        end

        local myAnim = myChar:FindFirstChild("Animate")
        if myAnim then
            for objName, data in pairs(originalState.Anims) do
                local myObj = myAnim:FindFirstChild(objName)
                if myObj and myObj:IsA("StringValue") then
                    myObj.Value = data.Value
                    for animName, animId in pairs(data.Anims) do
                        local myAnimTrack = myObj:FindFirstChild(animName)
                        if myAnimTrack and myAnimTrack:IsA("Animation") then myAnimTrack.AnimationId = animId end
                    end
                end
            end
        end
    end

    -- ==========================================
    -- دالة بناء الدرع الأجوف (بدون عقل، بدون فيزياء)
    -- ==========================================
    local function ApplyHollowArmor(sourceChar)
        local myChar = lp.Character
        if not myChar or not sourceChar then return end

        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        local sourceHum = sourceChar:FindFirstChildOfClass("Humanoid")
        if not myHum or not sourceHum then return end

        if myHum.RigType ~= sourceHum.RigType then
            Notify("Cryptic Hub ⚠️", "لا يمكن النسخ: نوع الجسم مختلف (R6 / R15)!\nRig types must match!")
            return
        end

        RestoreOriginalState()
        SaveOriginalState(myChar)

        -- 1. مطابقة حجم جسمك الحقيقي ليناسب السكن (لمنع المربعات والتشوه)
        local scales = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
        for _, scale in ipairs(scales) do
            local sVal = sourceHum:FindFirstChild(scale)
            local tVal = myHum:FindFirstChild(scale)
            if sVal and tVal and sVal:IsA("NumberValue") and tVal:IsA("NumberValue") then 
                tVal.Value = sVal.Value 
            end
        end
        
        -- نسخ طريقة المشي والرقص
        local targetAnimate = sourceChar:FindFirstChild("Animate")
        local myAnimate = myChar:FindFirstChild("Animate")
        if targetAnimate and myAnimate then
            for _, obj in ipairs(targetAnimate:GetChildren()) do
                local myObj = myAnimate:FindFirstChild(obj.Name)
                if myObj and obj:IsA("StringValue") and myObj:IsA("StringValue") then
                    myObj.Value = obj.Value
                    for _, anim in ipairs(obj:GetChildren()) do
                        if anim:IsA("Animation") then
                            local myAnimTrack = myObj:FindFirstChild(anim.Name)
                            if myAnimTrack and myAnimTrack:IsA("Animation") then myAnimTrack.AnimationId = anim.AnimationId end
                        end
                    end
                end
            end
        end

        task.wait(0.05) -- انتظار لجزء من الثانية لتطبيق الحجم

        -- 2. إخفاء جسمك بالكامل (أنت فقط لا تراه، الباقي يرونك طبيعي)
        for _, v in ipairs(myChar:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Transparency = 1
            elseif v:IsA("Decal") and v.Name == "face" then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Highlight") or v:IsA("ForceField") then
                v.Enabled = false
            end
        end

        -- 3. استنساخ الهدف وتفريغه من عقله ليكون درعاً فقط
        sourceChar.Archivable = true
        local fakeClone = sourceChar:Clone()
        fakeClone.Name = "CrypticArmor"

        -- 🔴 الضربة القاضية: تدمير عقل الدمية لمنع الطيران والتحرك التلقائي
        local fakeHum = fakeClone:FindFirstChildOfClass("Humanoid")
        if fakeHum then fakeHum:Destroy() end

        for _, v in ipairs(fakeClone:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Tool") or v:IsA("BodyMover") or v:IsA("BodyVelocity") or v:IsA("AlignPosition") then
                v:Destroy()
            elseif v:IsA("Motor6D") then
                -- تدمير العظام المزيفة لكي لا تعيق العظام الحقيقية
                v:Destroy() 
            elseif v:IsA("BasePart") then
                v.Anchored = false
                v.CanCollide = false
                v.Massless = true
                v.CanTouch = false
                v.CanQuery = false
                if v.Name == "HumanoidRootPart" then v.Transparency = 1 end

                -- لحام كل قطعة من الدمية بالقطعة الحقيقية في جسمك لتعمل بشكل مثالي
                local myPart = myChar:FindFirstChild(v.Name)
                if myPart then
                    -- منع التصادم النهائي
                    local ncc = Instance.new("NoCollisionConstraint")
                    ncc.Part0 = v
                    ncc.Part1 = myPart
                    ncc.Parent = v

                    local weld = Instance.new("Weld")
                    weld.Name = "ArmorWeld"
                    weld.Part0 = myPart
                    weld.Part1 = v
                    weld.C0 = CFrame.new()
                    weld.C1 = CFrame.new()
                    weld.Parent = v
                end
            end
        end

        myHum.DisplayName = sourceHum.DisplayName
        fakeClone.Parent = myChar
    end

    -- ==========================================
    -- بناء الواجهة
    -- ==========================================
    Tab:AddLabel("⚠️ الميزة لك فقط (باقي السيرفر يشوفك طبيعي)")

    local PlayerDropdown = Tab:AddPlayerSelector("اختر اللاعب / Select Player", "ابحث عن لاعب / Search...", function(selected)
        targetPlayer = (typeof(selected) == "Instance" and selected:IsA("Player")) and selected or nil
        
        if isToggleOn and targetPlayer and targetPlayer.Character then
            pcall(function()
                ApplyHollowArmor(targetPlayer.Character)
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
                ApplyHollowArmor(targetPlayer.Character)
                Notify("Cryptic Hub 🎭", "✅ تم النسخ! تحكمك حر وطبيعي 100%!")
            end)
        else
            pcall(function()
                RestoreOriginalState()
                Notify("Cryptic Hub 🔄", "✅ تم استرجاع سكنك الأصلي!")
            end)
        end
    end)

    lp.CharacterAdded:Connect(function()
        originalState = nil 
        task.delay(1, function()
            if isToggleOn and targetPlayer and targetPlayer.Character then
                ApplyHollowArmor(targetPlayer.Character)
            end
        end)
    end)

    Tab:AddLine()
end
