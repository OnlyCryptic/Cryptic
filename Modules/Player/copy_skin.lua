-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين الشامل (إصدار خالي من الأخطاء 100%) ]]
-- المطور: يامي | الوصف: نسخ جبري شامل (اكسسوارات، جسم، مشية، اسم) بدون الاعتماد على الويب

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
    local PlayerDropdown = Tab:AddPlayerSelector("اختر اللاعب / Select Player", "ابحث عن لاعب / Search...", function(selected)
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
                -- 1. تنظيف سكنك الحالي بالكامل (مسح ملابسك)
                for _, v in ipairs(myChar:GetChildren()) do
                    if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") then
                        v:Destroy()
                    end
                end
                local myHead = myChar:FindFirstChild("Head")
                if myHead then
                    for _, v in ipairs(myHead:GetChildren()) do
                        if v:IsA("Decal") then v:Destroy() end -- مسح وجهك
                    end
                end

                -- 2. نسخ الملابس، الألوان، والإكسسوارات (شعر، قبعات)
                for _, v in ipairs(targetChar:GetChildren()) do
                    if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") then
                        v:Clone().Parent = myChar
                    elseif v:IsA("Accessory") then
                        -- إضافة الإكسسوارات بالطريقة الصحيحة بدون تكسيرها
                        myHum:AddAccessory(v:Clone())
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

                -- 4. نسخ أبعاد الجسم (طول، عرض، نحافة) والاسم
                if targetHum then
                    myHum.DisplayName = targetHum.DisplayName
                    local scales = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
                    for _, scale in ipairs(scales) do
                        local sVal = targetHum:FindFirstChild(scale)
                        local tVal = myHum:FindFirstChild(scale)
                        if sVal and tVal and sVal:IsA("NumberValue") and tVal:IsA("NumberValue") then
                            tVal.Value = sVal.Value -- نقل الحجم
                        end
                    end
                end

                -- 5. نسخ الانيميشن (طريقة المشي، الركض، القفز)
                local targetAnimate = targetChar:FindFirstChild("Animate")
                local myAnimate = myChar:FindFirstChild("Animate")
                if targetAnimate and myAnimate then
                    for _, obj in ipairs(targetAnimate:GetChildren()) do
                        local myObj = myAnimate:FindFirstChild(obj.Name)
                        if myObj then
                            if obj:IsA("StringValue") and myObj:IsA("StringValue") then
                                myObj.Value = obj.Value
                            end
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

                Notify("Cryptic Hub 🎭", "✅ تم النسخ بالكامل (إكسسوارات، مشية، جسم)!\nEverything fully copied!")
            end)
        else
            -- 🟢 إيقاف الميزة (الرجوع للسكن الأصلي)
            pcall(function()
                -- جلب سكنك الأصلي من حسابك في روبلوكس مباشرة 
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
