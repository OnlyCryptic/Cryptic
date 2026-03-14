-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (إصدار اللحام الوهمي) ]]
-- المطور: يامي | الوصف: نسخ محلي شامل يركب الإكسسوارات والمشية غصباً عن السيرفر

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    local targetPlayer = nil 
    local originalDisplayName = lp.DisplayName 

    -- دالة الإشعارات (عربي / إنجليزي)
    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 })
        end)
    end

    -- 1. قائمة اختيار اللاعبين
    local PlayerDropdown = Tab:AddPlayerSelector("اختر اللاعب / Select Player", ".ابحث عن لاعب / Search...", function(selected)
        if typeof(selected) == "Instance" and selected:IsA("Player") then
            targetPlayer = selected
        else
            targetPlayer = nil
        end
    end)
    
    local function UpdateDropdown()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then table.insert(list, p) end
        end
        if PlayerDropdown and PlayerDropdown.UpdateList then
            PlayerDropdown.UpdateList(list) 
        end
    end
    
    UpdateDropdown()
    Players.PlayerAdded:Connect(UpdateDropdown)
    Players.PlayerRemoving:Connect(UpdateDropdown)
    
    Tab:AddLabel("⚠️ الميزة لك فقط / Only you can see the skin")

    -- 2. زر التشغيل والإيقاف الشامل للنسخ
    Tab:AddToggle("تفعيل السكن المستنسخ / Copy Skin", function(state)
        local myChar = lp.Character
        local myHum = myChar and myChar:FindFirstChild("Humanoid")
        if not myHum then return end

        if state then
            -- 🟢 تفعيل النسخ (تشغيل)
            if not targetPlayer or not targetPlayer.Character then
                Notify("Cryptic Hub ⚠️", "يرجى اختيار لاعب موجود باللعبة!\nPlease select a valid player!")
                return
            end
            
            local targetChar = targetPlayer.Character
            local targetHum = targetChar:FindFirstChild("Humanoid")
            
            pcall(function()
                -- 1. مسح ملابسك وإكسسواراتك الحالية
                for _, v in ipairs(myChar:GetChildren()) do
                    if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") then
                        v:Destroy()
                    end
                end
                local myHead = myChar:FindFirstChild("Head")
                if myHead then
                    for _, v in ipairs(myHead:GetChildren()) do
                        if v:IsA("Decal") then v:Destroy() end
                    end
                end

                -- 2. نسخ الملابس والإكسسوارات (بنظام اللحام الوهمي)
                for _, v in ipairs(targetChar:GetChildren()) do
                    if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") then
                        v:Clone().Parent = myChar
                    elseif v:IsA("Accessory") then
                        local clone = v:Clone()
                        local handle = clone:FindFirstChild("Handle")
                        
                        if handle then
                            -- مسح لحام اللاعب القديم
                            for _, w in ipairs(handle:GetChildren()) do
                                if w:IsA("Weld") or w:IsA("Motor6D") or w.Name == "AccessoryWeld" then
                                    w:Destroy()
                                end
                            end
                            
                            clone.Parent = myChar
                            
                            -- إنشاء لحام وهمي جديد يربط الإكسسوار بجسمك أنت
                            local att = handle:FindFirstChildOfClass("Attachment")
                            if att then
                                local targetPart = nil
                                local targetAtt = nil
                                for _, part in ipairs(myChar:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        targetAtt = part:FindFirstChild(att.Name)
                                        if targetAtt then
                                            targetPart = part
                                            break
                                        end
                                    end
                                end
                                
                                if targetPart and targetAtt then
                                    local weld = Instance.new("Weld")
                                    weld.Name = "FakeAccessoryWeld"
                                    weld.Part0 = handle
                                    weld.Part1 = targetPart
                                    weld.C0 = att.CFrame
                                    weld.C1 = targetAtt.CFrame
                                    weld.Parent = handle
                                end
                            end
                        end
                    end
                end

                -- 3. نسخ الوجه (الفيس)
                local targetHead = targetChar:FindFirstChild("Head")
                if targetHead and myHead then
                    for _, v in ipairs(targetHead:GetChildren()) do
                        if v:IsA("Decal") then
                            v:Clone().Parent = myHead
                        end
                    end
                end

                -- 4. نسخ أبعاد الجسم والاسم
                if targetHum then
                    myHum.DisplayName = targetHum.DisplayName
                    local scales = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
                    for _, scale in ipairs(scales) do
                        local sVal = targetHum:FindFirstChild(scale)
                        local tVal = myHum:FindFirstChild(scale)
                        if sVal and tVal and sVal:IsA("NumberValue") and tVal:IsA("NumberValue") then
                            tVal.Value = sVal.Value 
                        end
                    end
                end

                -- 5. نسخ الانيميشن (طريقة المشي والركض)
                local targetAnimate = targetChar:FindFirstChild("Animate")
                local myAnimate = myChar:FindFirstChild("Animate")
                if targetAnimate and myAnimate then
                    for _, obj in ipairs(targetAnimate:GetChildren()) do
                        local myObj = myAnimate:FindFirstChild(obj.Name)
                        if myObj and obj:IsA("StringValue") and myObj:IsA("StringValue") then
                            myObj.Value = obj.Value
                            for _, anim in ipairs(obj:GetChildren()) do
                                if anim:IsA("Animation") then
                                    local myAnim = myObj:FindFirstChild(anim.Name)
                                    if myAnim and myAnim:IsA("Animation") then
                                        myAnim.AnimationId = anim.AnimationId
                                    end
                                end
                            end
                        end
                    end
                end

                Notify("Cryptic Hub 🎭", "✅ تم النسخ بالكامل (إكسسوارات وهمية، مشية، جسم)!\nEverything fully copied locally!")
            end)
        else
            -- 🟢 إيقاف الميزة (الرجوع للسكن الأصلي من سيرفر روبلوكس)
            pcall(function()
                local myDesc = Players:GetHumanoidDescriptionFromUserId(lp.UserId)
                if myDesc then
                    myHum:ApplyDescription(myDesc)
                end
                myHum.DisplayName = originalDisplayName
                
                Notify("Cryptic Hub 🔄", "✅ تم استرجاع سكنك الأصلي!\nOriginal skin restored!")
            end)
        end
    end)

    Tab:AddLine()
end
